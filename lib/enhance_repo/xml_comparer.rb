# Encoding: utf-8
#
# The MIT License
#
# Copyright (c) 2009:
#
# Thilo Utke (thilo[at]upstream-berlin[dot]com)
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'nokogiri'
require 'active_support/core_ext/hash/keys'

class XmlComparer
  attr_reader :missing_nodes, :different_nodes, :superfluous_nodes

  def initialize(options = {})
    options.symbolize_keys!
    @custom_matcher = options.delete(:custom_matcher)
    @show_messages = options.delete(:show_messages)
  end
  def compare(target, sample)
    @target_doc = Nokogiri::XML::Document.parse(target, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)
    @sample_doc = Nokogiri::XML::Document.parse(sample, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)
    @missing_nodes = []
    @different_nodes = []
    @superfluous_nodes = []
    standard_traverse_and_compare
    reverse_traverse_and_compare
    p result_messages if @show_messages
    are_equal?
  end

  def result_messages
    missing_result_messages
    superfluous_nodes_messages
    different_nodes_messages
  end

  private

  def are_equal?
    @missing_nodes.empty? && @different_nodes.empty? && @superfluous_nodes.empty?
  end

  def missing_result_messages
    puts "\nFollowing nodes are missing:\n" unless @missing_nodes.empty?
    @missing_nodes.each do |node|
      puts "#{node.to_s} at #{node.path}\n"
    end
  end

  def superfluous_nodes_messages
    puts "\nFollowing nodes are superfluous:\n" unless @superfluous_nodes.empty?
    @superfluous_nodes.each do |node|
      puts "#{node.to_s} at #{node.path}\n"
    end
  end

  def different_nodes_messages
    puts "\nFollowing nodes are different:\n" unless @different_nodes.empty?
    @different_nodes.each do |node_pair|
      puts "#{node_pair[0].to_s} vs #{node_pair[1].to_s} at #{node_pair[0].path}\n"
    end
  end


  def standard_traverse_and_compare
    traverse_and_compare(@target_doc, @sample_doc)
  end

  def reverse_traverse_and_compare
    traverse_and_compare(@sample_doc, @target_doc)
  end

  def traverse_and_compare(doc, other_doc)
    doc.root.traverse do |node|
      other_node = find_sibling_in_other_doc(node, other_doc)
      if other_node.nil?
        add_to_missing_or_superfluous(node, doc)
      else
        @different_nodes << [node, other_node] unless in_reverse_traverse?(doc) || equal_nodes?(node, other_node)
      end
    end
  end

  def find_sibling_in_other_doc(node, doc)
    sibling_in_other_doc = doc.search(node.path).first
    sibling_in_other_doc
  end

  def add_to_missing_or_superfluous(node, doc)
    (in_reverse_traverse?(doc) ? @superfluous_nodes : @missing_nodes) << node
  end

  def in_reverse_traverse?(doc)
    doc == @sample_doc
  end

  def equal_nodes?(node, other_node)
    return false unless node && other_node
    standard_compare(node, other_node) || custom_compare(node, other_node)
  end

  def standard_compare(node, other_node)
    if node.text?
      node.text.strip == other_node.text.strip
    else
      Set.new(node.keys) == Set.new(other_node.keys) && Set.new(node.values) == Set.new(other_node.values)
    end
  end

  def custom_compare(node, other_node)
    return false unless @custom_matcher
    @custom_matcher.call(node) && @custom_matcher.call(other_node)
  end
end

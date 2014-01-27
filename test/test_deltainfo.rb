# Encoding: utf-8
#--
#
# enhancerepo is a rpm-md repository metadata tool.
# Copyright (C) 2008, 2009 Novell Inc.
# Author: Duncan Mac-Vicar P. <dmacvicar@suse.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.
#
#++
#
require File.join(File.dirname(__FILE__), 'test_helper')
require 'enhance_repo'
require 'stringio'

describe EnhanceRepo::RpmMd::DeltaInfo do

  before do
    @deltainfo = EnhanceRepo::RpmMd::DeltaInfo.new(test_data('rpms/repo-1'))
    @deltainfo.add_deltas
  end

  it "should generate the expected xml" do
    @deltainfo.wont_be_empty
    @deltainfo.delta_count.must_equal 1

    Zlib::GzipReader.open(test_data('rpms/repo-1/repodata/deltainfo.xml.gz')) do |expected_deltainfo|

      buffer = StringIO.new
      @deltainfo.write(buffer)

      buffer.string.must_be_xml_equivalent_with expected_deltainfo.read
    end
  end
end

require 'rspec'
require_relative '../lib/file_info'

describe FileInfo do
  describe '#ignore?' do
    it 'returns true for files with AAE extension in upper case' do
      FileInfo.new.ignored?('aaa/bbb/ccc.AAE').should be_true
    end

    it 'returns true for files with AAE extension in lower case' do
      FileInfo.new.ignored?('aaa/bbb/ccc.aae').should be_true
    end

    it 'returns false for files with extension that is not AAE' do
      FileInfo.new.ignored?('aaa/bbb/ccc.JPG').should be_false
      FileInfo.new.ignored?('aaa/bbb/ccc.MOV').should be_false
    end
  end
end

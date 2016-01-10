require 'rspec'
require_relative '../lib/file_info'
require_relative '../lib/duplicate_file_finder'

RSpec::Matchers.define :contain_fileset do |expected|
  match do |actual|
    filesets_contains(actual, expected)
  end
end

RSpec::Matchers.define :equal_to_fileset do |expected|
  match do |actual|
    filesets_are_equal(actual, expected)
  end

  def filesets_are_equal(actual, expected)
    actual.count.should == expected.count
    expected.each { |fileset|
      actual.should contain_fileset fileset
    }
  end
end

def filesets_contains(filesets, expected)
  filesets.each { |fileset|
    return true if fileset.sort == expected.sort
  }
  false
end


describe DuplicateFileFinder do
  let(:folder) { 'some_folder' }
  let(:some_size) { 1000 }
  let(:file_info) { FileInfo.new() }

  before do
    file_info.stub(:file?).and_return(true)
    file_info.stub(:ignored?).and_return(false)
  end

  it 'should find duplicates' do
    some_hash = 'some_hash'

    file_info.stub(:dir_glob).with("#{folder}/**/*")
    .and_yield('file1.bin')
    .and_yield('file2.bin')

    file_info.stub(:size).with('file1.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file1.bin').and_return(some_hash)

    file_info.stub(:size).with('file2.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file2.bin').and_return(some_hash)

    duplicate_file_finder = DuplicateFileFinder.new(file_info)
    duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets([folder])

    duplicate_file_sets.count.should == 1
  end

  it 'should not identify as duplicate if sizes are different' do
    file_info.stub(:dir_glob).with("#{folder}/**/*")
    .and_yield('file1.bin')
    .and_yield('file2.bin')

    file_info.stub(:size).with('file1.bin').and_return(1000)
    file_info.stub(:size).with('file2.bin').and_return(1001)

    duplicate_file_finder = DuplicateFileFinder.new(file_info)

    duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets([folder])

    duplicate_file_sets.count.should == 0
  end

  it 'should not identify as duplicate if sizes are same but contents are different' do
    file_info.stub(:dir_glob).with("#{folder}/**/*")
    .and_yield('file1.bin')
    .and_yield('file2.bin')

    file_info.stub(:size).with('file1.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file1.bin').and_return('some hash')
    file_info.stub(:size).with('file2.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file2.bin').and_return('some other hash')

    duplicate_file_finder = DuplicateFileFinder.new(file_info)

    duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets([folder])

    duplicate_file_sets.count.should == 0
  end


  it 'should identify multiple sets of duplicates' do
    file_info.stub(:dir_glob).with("#{folder}/**/*")
    .and_yield('file1.bin')
    .and_yield('file2.bin')
    .and_yield('file1copy.bin')
    .and_yield('file2copy.bin')

    file_info.stub(:size).with('file1.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file1.bin').and_return('some hash')
    file_info.stub(:size).with('file1copy.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file1copy.bin').and_return('some hash')
    file_info.stub(:size).with('file2.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file2.bin').and_return('some other hash')
    file_info.stub(:size).with('file2copy.bin').and_return(some_size)
    file_info.stub(:content_hash).with('file2copy.bin').and_return('some other hash')

    duplicate_file_finder = DuplicateFileFinder.new(file_info)

    duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets([folder])

    duplicate_file_sets.should equal_to_fileset [ ['file1.bin', 'file1copy.bin'], ['file2.bin', 'file2copy.bin']]
  end

  it 'should ignore ignored files' do
    file_info.stub(:dir_glob).with("#{folder}/**/*")
      .and_yield('file1.AAE')
      .and_yield('file2.AAE')

    file_info.stub(:size).with('file1.AAE').and_return(some_size)
    file_info.stub(:size).with('file2.AAE').and_return(some_size)

    file_info.stub(:ignored?).with('file1.AAE').and_return(true)
    file_info.stub(:ignored?).with('file2.AAE').and_return(true)

    duplicate_file_finder = DuplicateFileFinder.new(file_info)

    duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets([folder])

    duplicate_file_sets.count.should == 0
  end
end

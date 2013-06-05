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

  it 'should find duplicates' do
    folder = 'some_folder'
    some_size = 1000
    some_hash = 'some_hash'

    file_info = FileInfo.new()

    file_info.stub(:file?).and_return(true)

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
    folder = 'some_folder'

    file_info = FileInfo.new()

    file_info.stub(:file?).and_return(true)

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
    folder = 'some_folder'
    some_size = 1000

    file_info = FileInfo.new()

    file_info.stub(:file?).and_return(true)

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
    folder = 'some_folder'
    some_size = 1000

    file_info = FileInfo.new()

    file_info.stub(:file?).and_return(true)

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

    #duplicate_file_sets.count.should == 2
    #duplicate_file_sets.should contain_fileset %w(file1.bin file1copy.bin)
    #duplicate_file_sets.should contain_fileset %w(file2.bin file2copy.bin)

    duplicate_file_sets.should equal_to_fileset [ ['file1.bin', 'file1copy.bin'], ['file2.bin', 'file2copy.bin']]
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-1.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [%w(IMG_1234-1.JPG IMG_1234.JPG)]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-001.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [%w(IMG_1234-001.JPG IMG_1234.JPG)]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234 copy.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [ ['IMG_1234.JPG', 'IMG_1234 copy.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "Copy of IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [ ['IMG_1234.JPG', 'Copy of IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "2013-02 (FEB)/IMG_1234.JPG" as original when compared to "2013-03 (MAR)/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [ ['2013-03 (MAR)/IMG_1234.JPG', '2013-02 (FEB)/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('2013-02 (FEB)/IMG_1234.JPG').should == true
  end

  it 'should identify "whatever/Original/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [ ['whatever/IMG_1234.JPG', 'whatever/Original/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('whatever/Original/IMG_1234.JPG').should == true
  end

  it 'should identify "whatever/.picasaoriginal/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new(FileInfo.new())

    duplicate_file_sets = [ ['whatever/IMG_1234.JPG', 'whatever/.picasaoriginal/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('whatever/.picasaoriginal/IMG_1234.JPG').should == true
  end

  #it 'should identify "IMG_1234_some_description.JPG" as original when compared to "IMG_1234.JPG"' do
  #  duplicate_file_finder = DuplicateFileFinder.new
  #
  #  duplicate_file_sets = [ ['IMG_1234.JPG', 'IMG_1234_some_description.JPG'] ]
  #  result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
  #  result.has_key?('IMG_1234_some_description.JPG').should == true
  #end

  it 'should correctly identify file names that looks like an original file' do
    'MVI_1234-1.JPG'.looks_like_original_file_name?.should == false
    'MVI_1234.AVI'.looks_like_original_file_name?.should == true
    'IMG_1234.JPG'.looks_like_original_file_name?.should == true
    'CRW_1234.CRW'.looks_like_original_file_name?.should == true
    'DSC01234.JPG'.looks_like_original_file_name?.should == true
  end
end
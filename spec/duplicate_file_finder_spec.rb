require 'rspec'
require_relative '../lib/duplicate_file_finder'

describe DuplicateFileFinder do

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-1.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [%w(IMG_1234-1.JPG IMG_1234.JPG)]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-001.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [%w(IMG_1234-001.JPG IMG_1234.JPG)]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234 copy.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [ ['IMG_1234.JPG', 'IMG_1234 copy.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "Copy of IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [ ['IMG_1234.JPG', 'Copy of IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('IMG_1234.JPG').should == true
  end

  it 'should identify "2013-02 (FEB)/IMG_1234.JPG" as original when compared to "2013-03 (MAR)/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [ ['2013-03 (MAR)/IMG_1234.JPG', '2013-02 (FEB)/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('2013-02 (FEB)/IMG_1234.JPG').should == true
  end

  it 'should identify "whatever/Original/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [ ['whatever/IMG_1234.JPG', 'whatever/Original/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('whatever/Original/IMG_1234.JPG').should == true
  end

  it 'should identify "whatever/.picasaoriginal/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    duplicate_file_finder = DuplicateFileFinder.new

    duplicate_file_sets = [ ['whatever/IMG_1234.JPG', 'whatever/.picasaoriginal/IMG_1234.JPG'] ]
    result = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)
    result.has_key?('whatever/.picasaoriginal/IMG_1234.JPG').should == true
  end

  it 'should correctly identify file names that looks like an original file' do
    'MVI_1234-1.JPG'.looks_like_original_file_name?.should == false
    'MVI_1234.AVI'.looks_like_original_file_name?.should == true
    'IMG_1234.JPG'.looks_like_original_file_name?.should == true
    'CRW_1234.CRW'.looks_like_original_file_name?.should == true
    'DSC01234.JPG'.looks_like_original_file_name?.should == true
  end
end
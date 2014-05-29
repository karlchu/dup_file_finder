require 'rspec'
require_relative '../lib/original_finder'

describe OriginalFinder do

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-1.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(%w(IMG_1234-1.JPG IMG_1234.JPG))

    result.original.should == 'IMG_1234.JPG'
    result.duplicates.should =~ ['IMG_1234-1.JPG']
  end

  it 'should return other files that are not original as duplicates' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(%w(IMG_1234-1.JPG IMG_1234.JPG IMG_1234_copy2.JPG))

    result.original.should == 'IMG_1234.JPG'
    result.duplicates.should =~ ['IMG_1234-1.JPG', 'IMG_1234_copy2.JPG']
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234-001.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(%w(IMG_1234-001.JPG IMG_1234.JPG))

    result.original.should == 'IMG_1234.JPG'
    result.duplicates.should =~ ['IMG_1234-001.JPG']
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "IMG_1234 copy.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(['IMG_1234.JPG', 'IMG_1234 copy.JPG'])

    result.original.should == 'IMG_1234.JPG'
    result.duplicates.should =~ ['IMG_1234 copy.JPG']
  end

  it 'should identify "IMG_1234.JPG" as original when compared to "Copy of IMG_1234.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(['IMG_1234.JPG', 'Copy of IMG_1234.JPG'])

    result.original.should == 'IMG_1234.JPG'
    result.duplicates.should =~ ['Copy of IMG_1234.JPG']
  end

  it 'should identify "2013-02 (FEB)/IMG_1234.JPG" as original when compared to "2013-03 (MAR)/IMG_1234.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(['2013-03 (MAR)/IMG_1234.JPG', '2013-02 (FEB)/IMG_1234.JPG'])

    result.original.should == '2013-02 (FEB)/IMG_1234.JPG'
    result.duplicates.should =~ ['2013-03 (MAR)/IMG_1234.JPG']
  end

  it 'should identify "whatever/Original/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(['whatever/IMG_1234.JPG', 'whatever/Original/IMG_1234.JPG'])

    result.original.should == 'whatever/Original/IMG_1234.JPG'
    result.duplicates.should =~ ['whatever/IMG_1234.JPG']
  end

  it 'should identify "whatever/.picasaoriginal/IMG_1234.JPG" as original when compared to "whatever/IMG_1234.JPG"' do
    original_finder = OriginalFinder.new
    result = original_finder.find_original(['whatever/IMG_1234.JPG', 'whatever/.picasaoriginal/IMG_1234.JPG'])

    result.original.should == 'whatever/.picasaoriginal/IMG_1234.JPG'
    result.duplicates.should =~ ['whatever/IMG_1234.JPG']
  end

  #it 'should identify "IMG_1234_some_description.JPG" as original when compared to "IMG_1234.JPG"' do
  #  original_finder = OriginalFinder.new
  #  result = original_finder.find_original(['IMG_1234.JPG', 'IMG_1234_some_description.JPG'])
  #
  #  result.original.should == 'IMG_1234_some_description.JPG'
  #  result.duplicates.should =~ ['IMG_1234.JPG']
  #end

  it 'should identify file with a containing folder that is closest to its media creation date as original' do
    media_datetime = Time.parse('2014-04-27 12:44:24 +1100')
    file_info = Object.new
    FileInfo.stub(:new).and_return(file_info)
    file_info.stub(:media_datetime).with('whatever/2014-04-27/IMG_1234.JPG').and_return(media_datetime)
    file_info.stub(:media_datetime).with('whatever/2011-06-09/IMG_1234.JPG').and_return(media_datetime)

    original_finder = OriginalFinder.new
    result = original_finder.find_original(['whatever/2014-04-27/IMG_1234.JPG', 'whatever/2011-06-09/IMG_1234.JPG'])

    result.original.should == 'whatever/2014-04-27/IMG_1234.JPG'
    result.duplicates.should =~ ['whatever/2011-06-09/IMG_1234.JPG']
  end

  it 'should identify file with a containing folder that matches its media creation date as original' do
    original_path = 'whatever/2014-04-27/IMG_1234.JPG'
    duplicate_path = 'whatever/not_a_date/IMG_1234.JPG'
    media_datetime = Time.parse('2014-04-27 12:44:24 +1100')

    file_info = Object.new
    FileInfo.stub(:new).and_return(file_info)
    file_info.stub(:media_datetime).with(original_path).and_return(media_datetime)
    file_info.stub(:media_datetime).with(duplicate_path).and_return(media_datetime)

    original_finder = OriginalFinder.new
    result = original_finder.find_original([original_path, duplicate_path])

    result.original.should == original_path
    result.duplicates.should =~ [duplicate_path]
  end

  it 'should determine original if both files contained by a folder that matches its media creation date' do
    original_path = 'first/2014-04-27/IMG_1234.JPG'
    duplicate_path = 'second/2014-04-27/IMG_1234.JPG'
    media_datetime = Time.parse('2014-04-27 12:44:24 +1100')

    file_info = Object.new
    FileInfo.stub(:new).and_return(file_info)
    file_info.stub(:media_datetime).with(original_path).and_return(media_datetime)
    file_info.stub(:media_datetime).with(duplicate_path).and_return(media_datetime)

    original_finder = OriginalFinder.new
    result = original_finder.find_original([duplicate_path, original_path])

    result.original.should == original_path
    result.duplicates.should =~ [duplicate_path]
  end

  it 'should correctly identify file names that looks like an original file' do
    'MVI_1234-1.JPG'.looks_like_original_file_name?.should == false
    'MVI_1234.AVI'.looks_like_original_file_name?.should == true
    'IMG_1234.JPG'.looks_like_original_file_name?.should == true
    'CRW_1234.CRW'.looks_like_original_file_name?.should == true
    'DSC01234.JPG'.looks_like_original_file_name?.should == true
  end

end

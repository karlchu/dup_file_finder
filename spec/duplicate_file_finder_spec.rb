require 'rspec'
require 'duplicate_file_finder'

describe DuplicateFileFinder do

  it 'should index file size' do
    finder = DuplicateFileFinder.new()
    test_dir = 'test_data/index_file_size'
    result = finder.index_file_size_in_dir("#{test_dir}/**/*")

    result.should == {
        524288 => ["#{test_dir}/file_1024-2.bin", "#{test_dir}/file_1024.bin"],
        1024000 => ["#{test_dir}/file_2000.bin"],
    }
  end

  it 'should find duplicate files by their digest' do
    finder = DuplicateFileFinder.new()
    test_dir = 'test_data/duplicate_files'
    filenames = %W(#{test_dir}/file1.bin #{test_dir}/file2.bin #{test_dir}/file2-copy.bin)

    duplicate_file_sets = finder.find_duplicate_files_by_digest(filenames)

    duplicate_file_sets.should == [["#{test_dir}/file2.bin", "#{test_dir}/file2-copy.bin"]]
  end

  it 'should find nothing when there is no duplicate' do
    finder = DuplicateFileFinder.new()
    test_dir = 'test_data/duplicate_files'
    filenames = ["#{test_dir}/file1.bin", "#{test_dir}/file2.bin"]

    duplicate_file_sets = finder.find_duplicate_files_by_digest(filenames)

    duplicate_file_sets.should be_empty
  end
end
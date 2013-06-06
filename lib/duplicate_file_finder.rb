require 'digest/md5'
require_relative '../lib/file_info'
require_relative '../lib/original_finder'

class DuplicateFileFinder

  # @param [FileInfo] file_info
  def initialize(file_info)
    @file_info = file_info
    @original_finder = OriginalFinder.new()
  end

  # @return [Array] An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  # @param [Array] folders_to_check An array of folders to check for duplicates
  def find_duplicate_file_sets(folders_to_check)
    filesize_hash = index_file_size_in_dir(folders_to_check)

    duplicate_file_set = []
    filesize_hash.values.each do |files_of_same_size|
      if files_of_same_size.size > 1
        find_duplicate_files_by_digest = find_duplicate_files_by_digest(files_of_same_size)
        duplicate_file_set.concat find_duplicate_files_by_digest
      end
    end
    duplicate_file_set
  end

  # Create a hash that the key is the "original" file name. The values of the hash are arrays of file names
  # that are duplicates of the file identified by the key.
  # @return [Hash]
  # @param [Array] duplicate_file_sets An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  def find_originals_in_duplicate_file_sets(duplicate_file_sets)
    duplicates_hash = Hash.new
    duplicate_file_sets.each do |duplicate_files|
      original_and_duplicates = @original_finder.find_original(duplicate_files)
      original = original_and_duplicates.original
      duplicates = original_and_duplicates.duplicates
      duplicates_hash[original] = duplicates
    end
    duplicates_hash
  end

  # @return [Hash] A hash keyed by the file size. The value is an array of file names
  # that have that file size
  # @param [Array] folders_to_check An array of folders for which to index the file size.
  def index_file_size_in_dir(folders_to_check)
    filesize_hashes = Hash.new { |hash, key| hash[key] = [] }

    folders_to_check.each do |folder_to_check|
      dir_glob_pattern = "#{folder_to_check}/**/*"
      @file_info.dir_glob(dir_glob_pattern) do |filename|
        next unless @file_info.file?(filename)

        file_size = @file_info.size(filename)
        filesize_hashes[file_size] << filename
      end
    end

    filesize_hashes
  end

  # @return [Array] An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  # @param [Array] filenames
  def find_duplicate_files_by_digest(filenames)
    content_hashes = Hash.new { |hash, key| hash[key] = [] }

    filenames.each do |filename|
      $stderr.printf "### Computing the MD5 digest for file \"#{filename}\": "
      file_content_digest = @file_info.content_hash(filename)
      $stderr.puts "[#{file_content_digest}]"
      content_hashes[file_content_digest] << filename
    end

    duplicate_file_sets = Array.new

    content_hashes.values.each do |value|
      if value.size > 1
        duplicate_file_sets << value
      end
    end

    duplicate_file_sets
  end

  private :index_file_size_in_dir,
          :find_duplicate_files_by_digest
end
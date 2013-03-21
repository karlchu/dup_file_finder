require "digest/md5"

class DuplicateFileFinder

  # @return [Array] An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  def find_duplicate_file_sets(folder_to_check)
    filesize_hash = index_file_size_in_dir("#{folder_to_check}/**/*")

    duplicate_file_set = []
    filesize_hash.values.each do |files_of_same_size|
      if files_of_same_size.size > 1
        find_duplicate_files_by_digest = find_duplicate_files_by_digest(files_of_same_size)
        duplicate_file_set.concat find_duplicate_files_by_digest
      end
    end
    duplicate_file_set
  end

  # @return [Hash] A hash keyed by the file size. The value is an array of file names
  # that have that file size
  def index_file_size_in_dir(dir_glob_pattern)
    filesize_hashes = Hash.new { |hash, key| hash[key] = [] }
    Dir.glob(dir_glob_pattern, File::FNM_CASEFOLD) do |filename|
      next unless File.file?(filename)

      file_size = File.size(filename)
      filesize_hashes[file_size] << filename
    end
    filesize_hashes
  end

  # @return [Array] An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  # @param [Array] filenames
  def find_duplicate_files_by_digest(filenames)
    content_hashes = Hash.new { |hash, key| hash[key] = [] }

    filenames.each do |filename|
      printf "Computing the MD5 digest for file \"#{filename}\": "
      file_content_digest = Digest::MD5.file(filename).hexdigest
      puts "[#{file_content_digest}]"
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

end
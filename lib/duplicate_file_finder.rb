require 'digest/md5'

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

  # Create a hash that the key is the "original" file name. The values of the hash are arrays of file names
  # that are duplicates of the file identified by the key.
  # @return [Hash]
  # @param [Array] duplicate_file_sets An array of arrays. Each array contains the filenames of the files
  # that are the duplicate of each other
  def find_originals_in_duplicate_file_sets(duplicate_file_sets)
    duplicates_hash = Hash.new
    duplicate_file_sets.each do |duplicate_files|
      duplicate_files.sort! do |x, y|
        compare_files(x, y)
      end
      duplicates_hash[duplicate_files.shift] = duplicate_files
    end
    duplicates_hash
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
      $stderr.printf "### Computing the MD5 digest for file \"#{filename}\": "
      file_content_digest = Digest::MD5.file(filename).hexdigest
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

  def compare_files(x, y)
    x_path = File.dirname x
    y_path = File.dirname y
    x_filename = File.basename x
    y_filename = File.basename y

    if x_path == y_path
      return compare_filenames x_filename, y_filename
    end

    x_is_original = is_original_dir(x_path)
    y_is_original = is_original_dir(y_path)

    return -1 if x_is_original && !y_is_original
    return  1 if y_is_original && !x_is_original

    return -1 if y_path.start_with?(x_path)
    return  1 if x_path.start_with?(y_path)

    return x_path <=> y_path
  end

  def is_original_dir(dir)
    ['Original', '.picasaoriginal'].include? File.basename(dir)
  end

  def compare_filenames(x_filename, y_filename)
    x_basename = File.basename x_filename, '.*'
    y_basename = File.basename y_filename, '.*'

    x_basename.length - y_basename.length

    # MVI
    # IMG
    # DSC
    #
    #/-\d+$/.match File.basename(x, '.*')
  end

  private :index_file_size_in_dir,
          :find_duplicate_files_by_digest,
          :compare_files
          :compare_filenames

end
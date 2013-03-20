class DuplicateFileFinder
  def find_and_create_shell_script(folder_to_check, script_name)
    # TODO
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
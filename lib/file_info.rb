require 'digest/md5'

class FileInfo
  def file?(filename)
    File.file?(filename)
  end

  def size(file_path)
    File.size(file_path)
  end

  def content_hash(file_path)
    Digest::MD5.file(file_path).hexdigest
  end

  def dir_glob(dir_glob_pattern)
    Dir.glob(dir_glob_pattern, File::FNM_CASEFOLD) do |filename|
      yield filename
    end
  end
end
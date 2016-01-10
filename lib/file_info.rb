require 'digest/md5'
require 'mini_exiftool'

class FileInfo
  def initialize
    @ignore_pattern = Regexp.new('\.aae$', 'i')
  end

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

  def media_datetime(filename)
    begin
      media_info = MiniExiftool.new(filename)
      return media_info['createdate']
    rescue
      return nil
    end
  end

  def ignored?(filename)
    @ignore_pattern.match(filename) ? true : false
  end
end

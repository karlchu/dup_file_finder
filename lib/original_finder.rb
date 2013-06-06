require 'ostruct'

class ::String
  def looks_like_original_file_name?
    basename_regex = [
        /MVI_\d{4}$/,
        /IMG_\d{4}$/,
        /CRW_\d{4}$/,
        /DSC\d{5}$/,
    ]

    basename_regex.any? do |regex|
      File.basename(self, '.*').match regex
    end
  end
end

class OriginalFinder

  Result = Struct.new(:original, :duplicates)

  def find_original(filenames)
    filenames.sort! do |x, y|
      compare_files(x, y)
    end
    return Result.new(filenames.shift, filenames)
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

    return -1 if x_filename.looks_like_original_file_name? && !y_filename.looks_like_original_file_name?
    return  1 if y_filename.looks_like_original_file_name? && !x_filename.looks_like_original_file_name?

    x_basename.length - y_basename.length
  end

  private :compare_files
          :is_original_dir
          :compare_filenames

end
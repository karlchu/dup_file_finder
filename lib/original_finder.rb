require_relative './file_info'

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

  private

  def compare_files(x, y)
    @x_path = x
    @y_path = y
    @x_dir = File.dirname x
    @y_dir = File.dirname y
    @x_filename = File.basename x
    @y_filename = File.basename y

    return result_when_files_have_same_path ||
        result_when_one_file_in_original_dir ||
        result_when_one_file_in_parent_folder_of_the_other_file ||
        result_when_one_file_in_properly_dated_folder ||
        result_when_one_file_in_iphoto_library ||
        @x_dir <=> @y_dir
  end

  def result_when_files_have_same_path
    return compare_filenames(@x_filename, @y_filename) if @x_dir == @y_dir
  end

  def result_when_one_file_in_original_dir
    x_is_original = is_original_dir(@x_dir)
    y_is_original = is_original_dir(@y_dir)

    return -1 if x_is_original && !y_is_original
    return  1 if y_is_original && !x_is_original
    return nil
  end

  def result_when_one_file_in_parent_folder_of_the_other_file
    return -1 if @y_dir.start_with?(@x_dir)
    return  1 if @x_dir.start_with?(@y_dir)
    return nil
  end

  def result_when_one_file_in_properly_dated_folder
    x_dir_date = begin
      Date.parse(File.basename(@x_dir))
    rescue
      nil
    end
    y_dir_date = begin
      Date.parse(File.basename(@y_dir))
    rescue
      nil
    end

    media_datetime = FileInfo.new.media_datetime(@x_path)
    # This should never happen because the two files should be identical
    return nil if media_datetime.nil? || media_datetime != FileInfo.new.media_datetime(@y_path)
    media_date = media_datetime.to_date

    return -1 if x_dir_date == media_date && y_dir_date.nil?
    return  1 if y_dir_date == media_date && x_dir_date.nil?

    x_dir_date_diff = (media_date - x_dir_date).abs
    y_dir_date_diff = (media_date - y_dir_date).abs

    comparison = x_dir_date_diff <=> y_dir_date_diff
    return (comparison != 0) ? comparison : nil
  end

  def result_when_one_file_in_iphoto_library
    x_in_iphoto_dir = in_iphoto_dir?(@x_dir)
    y_in_iphoto_dir = in_iphoto_dir?(@y_dir)

    return -1 if y_in_iphoto_dir && !x_in_iphoto_dir
    return  1 if x_in_iphoto_dir && !y_in_iphoto_dir
    return nil
  end

  def is_original_dir(dir)
    ['Original', '.picasaoriginal'].include? File.basename(dir)
  end

  def in_iphoto_dir?(dir)
    !!(/\.photolibrary\// =~ dir)
  end

  def compare_filenames(x_filename, y_filename)
    x_basename = File.basename x_filename, '.*'
    y_basename = File.basename y_filename, '.*'

    return -1 if x_filename.looks_like_original_file_name? && !y_filename.looks_like_original_file_name?
    return 1 if y_filename.looks_like_original_file_name? && !x_filename.looks_like_original_file_name?

    x_basename.length - y_basename.length
  end

end

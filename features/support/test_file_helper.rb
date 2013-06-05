class TestFileHelper

  columns = [:file_sub_path, :content_type, :file_size, :copy_from]
  content_types = [:random, :zeros, :copy]

  def initialize
    @test_files = []
  end

  def create_test_file(base_dir, cucumber_table_hash)
    file_path = base_dir + File::SEPARATOR + cucumber_table_hash[:file_sub_path]

    @test_files << file_path

    case cucumber_table_hash[:content_type].to_sym
      when :random
        file_size = cucumber_table_hash[:file_size]
        create_file(file_path, file_size) { rand(256) }
      when :zeros
        file_size = cucumber_table_hash[:file_size]
        create_file(file_path, file_size) { 0 }
      when :copy
        src = base_dir + File::SEPARATOR + cucumber_table_hash[:copy_from]
        FileUtils.copy src, file_path
      else
    end
  end

  def create_file(file_path, file_size)
    FileUtils.mkdir_p(File.dirname(file_path))
    file = File.new file_path, 'wb'
    (0...Integer(file_size)).each do
      file.putc(yield)
    end
    file.close
  end


  def delete_test_files
    @test_files.each do |file|
      File.delete(file)
    end

    # TODO: clean up empty directories
  end


end
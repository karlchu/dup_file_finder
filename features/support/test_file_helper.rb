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
        FileUtils.mkdir_p(File.dirname(file_path))
        file = File.new file_path, 'wb'
        (0...Integer(cucumber_table_hash[:file_size])).each do
          file.putc(rand(256))
        end
        file.close
      when :zeros
        # Create a file with zeros
      when :copy
        src = base_dir + File::SEPARATOR + cucumber_table_hash[:copy_from]
        FileUtils.copy src, file_path
      else
    end
  end

  def delete_test_files
    @test_files.each do |file|
      File.delete(file)
    end

    # TODO: clean up empty directories
  end


end
require_relative 'write_bash_script_duplicates_processor.rb')

class WriteBashScriptMoveDuplicatesProcessor < WriteBashScriptDuplicatesProcessor

  def initialize(source_dir, destination_dir)
    @source_dir = source_dir
    @destination_dir = destination_dir
  end

  def process_duplicate(file)
    sub_path = file[@source_dir[0].length+1..-1]
    dest_file_path = "#{@destination_dir}#{File::SEPARATOR}#{sub_path}"
    write_script_line create_parent_directories_command(dest_file_path)
    write_script_line %!mv "#{escape_double_quotes(file)}" "#{escape_double_quotes(dest_file_path)}"!
    #$stdout.puts %!rm -f "#{escape_double_quotes(file)}"!
  end

  private

  def create_parent_directories_command(file_path)
    path_elements = File::split(file_path)
    path_elements.pop
    %!mkdir -p "#{escape_double_quotes(File::join(path_elements))}"!
  end

end

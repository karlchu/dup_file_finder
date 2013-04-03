class WriteBashScriptDuplicatesProcessor

  def initialize(source_dir, destination_dir)
    @source_dir = source_dir
    @destination_dir = destination_dir
  end

  # Writes the bash script to move the duplicates to $stdout.
  # Other messages are written out to $stderr.
  # @param [Hash] duplicates_hash Hash of arrays
  def process_duplicates(duplicates_hash)

    $stdout.puts '#!/bin/bash'
    $stdout.puts ''

    duplicates_hash.each do |file_to_keep, files_to_move|
      $stdout.puts "# Duplicates of #{file_to_keep}"
      files_to_move.each do |file|
        sub_path = file[@source_dir.length+1..-1]
        dest_file_path = "#{@destination_dir}#{File::SEPARATOR}#{sub_path}"
        $stdout.puts create_parent_directories_command(dest_file_path)
        $stdout.puts %!mv "#{escape_double_quotes(file)}" "#{escape_double_quotes(dest_file_path)}"!
      end
      $stdout.puts "\n"
    end
  end

  def create_parent_directories_command(file_path)
    path_elements = File::split(file_path)
    path_elements.pop
    %!mkdir -p "#{escape_double_quotes(File::join(path_elements))}"!
  end

  def escape_double_quotes(file)
    file.gsub('""', %[\"])
  end

  private :create_parent_directories_command
          :escape_double_quotes

end
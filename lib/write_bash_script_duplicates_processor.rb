class WriteBashScriptDuplicatesProcessor

  def initialize(source_dir, destination_dir)
    @source_dir = source_dir
    @destination_dir = destination_dir
  end

  # @param [Hash] duplicates_hash Hash of arrays
  # @return [String] the content of a bash script that will move the duplicates
  def process_duplicates(duplicates_hash)
    bash_script = String.new

    bash_script << "#!/bin/bash\n\n"
    duplicates_hash.each do |file_to_keep, files_to_move|
      puts "Duplicates of #{file_to_keep}:"
      files_to_move.each { |file| puts "    #{file}" }

      bash_script << "# Duplicates of #{file_to_keep}\n"
      files_to_move.each do |file|
        sub_path = file[@source_dir.length+1..-1]
        dest_file_path = "#{@destination_dir}#{File::SEPARATOR}#{sub_path}"
        bash_script << "mv \"#{file}\" \"#{dest_file_path}\"\n"
      end
      bash_script << "\n"
    end
    bash_script
  end

end
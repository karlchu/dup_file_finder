FOLDER_TO_CHECK = "test_data"
SCRIPT_NAME = "remove_empty_dir.sh"

bash_script = File.new SCRIPT_NAME, "w"

ignored_entries = %w{ .picasa.ini .DS_Store }
Dir.glob("#{FOLDER_TO_CHECK}/**/*/") do |dir|

  #$stderr.puts "#{dir}"

  dir_all_entries = Dir.entries(dir) - %w{ . .. }
  dir_non_ignored_entries = (dir_all_entries - ignored_entries)
  dir_ignored_entries = dir_all_entries & ignored_entries

  #$stderr.puts "  #{dir_all_entries}"
  #$stderr.puts "  #{dir_non_ignored_entries}"
  #$stderr.puts "  #{dir_ignored_entries}"

  next unless dir_non_ignored_entries.empty?

  $stderr.puts "Directory is \"empty\": #{dir}"
  bash_script.write "# Remove \"empty\" directory: #{dir}\n"
  if !dir_ignored_entries.empty?
    dir_ignored_entries.each do |f|
      message = "    [dir]#{File::SEPARATOR}#{f}"
      $stderr.puts message
      bash_script.write "# #{message}\n"
    end
  end
  bash_script.write "rm -Rf \"#{dir}\"\n\n"
end
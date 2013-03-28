require 'digest/md5'
require 'optparse'
require_relative 'lib/duplicate_file_finder'
require_relative 'lib/write_bash_script_duplicates_processor'
require_relative 'lib/runtime_parameters'

runtime_parameters = RuntimeParameters.new
runtime_parameters.parse ARGV

if runtime_parameters.show_help?
  puts runtime_parameters.help_message
  exit 1
end

folder_to_check = runtime_parameters.input_folder
to_folder = runtime_parameters.destination

duplicate_file_finder = DuplicateFileFinder.new
duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets(folder_to_check)

duplicates_hash = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)

write_bash_script_duplicates_processor = WriteBashScriptDuplicatesProcessor.new(folder_to_check, to_folder)
write_bash_script_duplicates_processor.process_duplicates(duplicates_hash)



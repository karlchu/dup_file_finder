require "digest/md5"
require_relative 'lib/duplicate_file_finder'

# TODO: Take in the FOLDER_TO_CHECK by command line parameter
FOLDER_TO_CHECK = "test_data"
# TODO: Take in the TO_FOLDER by command line parameter
TO_FOLDER = "test_data_duplicates"
# TODO: Take in the SCRIPT_NAME by command line parameter
SCRIPT_NAME = "do-the-move.sh"

# TODO: Make this cross-platform? (i.e. care a bit more about Windows?)

def compare_files(x, y)
  File.basename(x).length - File.basename(y).length
end


duplicate_file_sets = DuplicateFileFinder.new.find_duplicate_file_sets(FOLDER_TO_CHECK)

# Create a new hash that the key is the "original" file name. The values of the hash are arrays of file names
# that are duplicates of the file identified by the key.
duplicates_hash = Hash.new
duplicate_file_sets.each do |duplicate_files|
  duplicate_files.sort! do |x, y|
    compare_files(x, y)
  end
  duplicates_hash[duplicate_files.shift] = duplicate_files
end

bash_script = File.new SCRIPT_NAME, 'w'

bash_script.write "#!/bin/bash\n\n"
duplicates_hash.each do |file_to_keep, files_to_move|
  puts "Duplicates of #{file_to_keep}:"
  files_to_move.each {|file| puts "    #{file}"}

  bash_script.write "# Duplicates of #{file_to_keep}\n"
  files_to_move.each do |file|
    sub_path = file[FOLDER_TO_CHECK.length+1..-1]
    dest_file_path = "#{TO_FOLDER}#{File::SEPARATOR}#{sub_path}"
    bash_script.write "mv \"#{file}\" \"#{dest_file_path}\"\n"
  end
  bash_script.write "\n"
end

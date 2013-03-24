require 'digest/md5'
require_relative 'lib/duplicate_file_finder'
require_relative 'lib/write_bash_script_duplicates_processor'

# TODO: Take in the FOLDER_TO_CHECK by command line parameter
FOLDER_TO_CHECK = 'test_data'
# TODO: Take in the TO_FOLDER by command line parameter
TO_FOLDER = 'test_data_duplicates'

# TODO: Make this cross-platform? (i.e. care a bit more about Windows?)

duplicate_file_sets = DuplicateFileFinder.new.find_duplicate_file_sets(FOLDER_TO_CHECK)

def compare_files(x, y)
  File.basename(x).length - File.basename(y).length
end

# Create a new hash that the key is the "original" file name. The values of the hash are arrays of file names
# that are duplicates of the file identified by the key.
duplicates_hash = Hash.new
duplicate_file_sets.each do |duplicate_files|
  duplicate_files.sort! do |x, y|
    compare_files(x, y)
  end
  duplicates_hash[duplicate_files.shift] = duplicate_files
end

write_bash_script_duplicates_processor = WriteBashScriptDuplicatesProcessor.new(FOLDER_TO_CHECK, TO_FOLDER)
write_bash_script_duplicates_processor.process_duplicates(duplicates_hash)



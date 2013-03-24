require 'digest/md5'
require_relative 'lib/duplicate_file_finder'
require_relative 'lib/write_bash_script_duplicates_processor'

# TODO: Take in the FOLDER_TO_CHECK by command line parameter
FOLDER_TO_CHECK = 'test_data'
# TODO: Take in the TO_FOLDER by command line parameter
TO_FOLDER = 'test_data_duplicates'

# TODO: Make this cross-platform? (i.e. care a bit more about Windows?)

duplicate_file_finder = DuplicateFileFinder.new
duplicate_file_sets = duplicate_file_finder.find_duplicate_file_sets(FOLDER_TO_CHECK)

duplicates_hash = duplicate_file_finder.find_originals_in_duplicate_file_sets(duplicate_file_sets)

write_bash_script_duplicates_processor = WriteBashScriptDuplicatesProcessor.new(FOLDER_TO_CHECK, TO_FOLDER)
write_bash_script_duplicates_processor.process_duplicates(duplicates_hash)



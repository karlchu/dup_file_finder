require "digest/md5"
require_relative 'lib/duplicate_file_finder'

# TODO: Take in the FOLDER_TO_CHECK by command line parameter
#FOLDER_TO_CHECK = "/Volumes/Data/Picasa"
FOLDER_TO_CHECK = "test_data"
#FOLDER_TO_CHECK = "/Users/kchu/dev/duplicate_finder/test_data"
# TODO: Take in the TO_FOLDER by command line parameter
TO_FOLDER = "/Volumes/Data/picassa_duplicates"
# TODO: Take in the SCRIPT_NAME by command line parameter
SCRIPT_NAME = "do-the-move.sh"

# TODO: Make this cross-platform? (i.e. care a bit more about Windows?)

duplicate_file_finder = DuplicateFileFinder.new

dir_glob_pattern = "#{FOLDER_TO_CHECK}/**/*"

def compare_files(x, y)
  File.basename(x).length - File.basename(y).length
end

filesize_hash = duplicate_file_finder.index_file_size_in_dir(dir_glob_pattern)

puts 'File sets that have the same size:'
filesize_hash.values.each do |files_of_same_size|
  if files_of_same_size.size > 1
    puts "[ #{files_of_same_size.join("\n  ")}\n]"
  end
end

duplicates_hash = Hash.new
filesize_hash.values.each do |files_of_same_size|
  if files_of_same_size.size > 1

    duplicate_file_sets = duplicate_file_finder.find_duplicate_files_by_digest(files_of_same_size)

    # Create a new hash that the key is the "original" file name. The values of the hash are arrays of file names
    # that are duplicates of the file identified by the key.
    duplicate_file_sets.each do |duplicate_files|
      duplicate_files.sort! do |x, y|
        compare_files(x, y)
      end
      duplicates_hash[duplicate_files.shift] = duplicate_files
    end
  end
end

bash_script = File.new SCRIPT_NAME, "w"

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

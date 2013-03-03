require "digest/md5"

# TODO: Take in the FOLDER_TO_CHECK by command line parameter
FOLDER_TO_CHECK = "/Volumes/Data/Picasa"
#FOLDER_TO_CHECK = "test_data"
#FOLDER_TO_CHECK = "/Users/kchu/dev/duplicate_finder/test_data"
# TODO: Take in the TO_FOLDER by command line parameter
TO_FOLDER = "/Volumes/Data/picassa_duplicates"
# TODO: Take in the SCRIPT_NAME by command line parameter
SCRIPT_NAME = "do-the-move.sh"

# TODO: Make this cross-platform? (i.e. care a bit more about Windows?)

# Index and create digests for all the files within a directory
content_hashes = Hash.new {|hash, key| hash[key] = []}

Dir.glob("#{FOLDER_TO_CHECK}/**/*") do |f|
  next unless File.file?(f)

  printf "Computing the MD5 digest for file \"#{f}\": "
  file_content_digest = Digest::MD5.file(f).hexdigest
  puts "[#{file_content_digest}]"
  content_hashes[file_content_digest] << f
end

# Identify the files that have the same content hash (i.e. the files are identical)
duplicate_file_sets = Array.new
content_hashes.each do |key, value|
  if value.size > 1
    duplicate_file_sets << value
  end
end

# Create a new hash that the key is the "original" file name. The values of the hash are arrays of file names
# that are duplicates of the file identified by the key.
duplicates_hash = Hash.new
duplicate_file_sets.each do |duplicate_files|
  duplicate_files.sort! do |x, y|
    # TODO: Make this sorting more intelligent so that we keep the original file (e.g. IMG_1234.JPG)
    # rather than the duplicate file (e.g. IMG_1234-001.JPG, or IMG_1234 copy.JPG, etc.)
    File.basename(x).length - File.basename(y).length
  end
  duplicates_hash[duplicate_files.shift] = duplicate_files
end

bash_script = File.new SCRIPT_NAME, "w"

bash_script.write "#!/bin/bash\n\n"
duplicates_hash.each do |file_to_keep, files_to_move|
  puts "Duplicates of #{file_to_keep}:"
  files_to_move.each {|file| puts "    #{file}"}

  bash_script.write "# Duplicates of #{file_to_keep}\n"
  files_to_move.each do |file|
    sub_path = file[FOLDER_TO_CHECK.length+1..-1]
    destFilePath = "#{TO_FOLDER}#{File::SEPARATOR}#{sub_path}"
    bash_script.write "mv \"#{file}\" \"#{destFilePath}\"\n"
  end
  bash_script.write "\n"
end

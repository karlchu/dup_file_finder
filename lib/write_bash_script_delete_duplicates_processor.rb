require_relative 'write_bash_script_duplicates_processor.rb'

class WriteBashScriptDeleteDuplicatesProcessor < WriteBashScriptDuplicatesProcessor
  def process_duplicate(file)
    write_script_line %!  rm -f "#{escape_quotes(file)}"!
  end

  def write_original_file_comment(file_to_keep)
    write_script_line %Q{# rm -f "#{escape_quotes(file_to_keep)}" # Deemed original }
  end
end

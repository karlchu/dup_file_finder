require_relative 'write_bash_script_duplicates_processor.rb'

class WriteBashScriptDeleteDuplicatesProcessor < WriteBashScriptDuplicatesProcessor
  def process_duplicate(file)
    write_script_line %!rm -f "#{escape_double_quotes(file)}"!
  end
end

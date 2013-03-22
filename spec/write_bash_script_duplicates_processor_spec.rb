require 'rspec'
require_relative '../lib/write_bash_script_duplicates_processor'

describe WriteBashScriptDuplicatesProcessor do

  it 'should generate bash script' do
    processor = WriteBashScriptDuplicatesProcessor.new('src', 'dest')

    expected_script_content = <<EOS
#!/bin/bash

# Duplicates of src/path/file1.bin
mv "src/path/file1-copy.bin" "dest/path/file1-copy.bin"

EOS

    result = processor.process_duplicates 'src/path/file1.bin' => ['src/path/file1-copy.bin']

    result.should == expected_script_content
  end
end
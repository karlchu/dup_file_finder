require 'rspec'
require_relative '../lib/write_bash_script_move_duplicates_processor'

def capture_stdout(new_stdout)
  previous_stdout = $stdout
  $stdout = new_stdout
  yield
  new_stdout
ensure
  $stdout = previous_stdout
end

describe WriteBashScriptMoveDuplicatesProcessor do

  it 'should generate bash script with one duplicate file' do
    processor = WriteBashScriptMoveDuplicatesProcessor.new(['src'], 'dest')

    expected_script_content = <<EOS
#!/bin/bash

# Duplicates of src/path/file1.bin
mkdir -p "dest/path"
mv "src/path/file1-copy.bin" "dest/path/file1-copy.bin"

EOS

    string_io = StringIO.new
    capture_stdout(string_io) do
      processor.process_duplicates 'src/path/file1.bin' => ['src/path/file1-copy.bin']
    end

    string_io.string.should == expected_script_content
  end

  it 'should generate bash script with more than one duplicate file' do
    processor = WriteBashScriptMoveDuplicatesProcessor.new(['src'], 'dest')

    expected_script_content = <<EOS
#!/bin/bash

# Duplicates of src/path/file1.bin
mkdir -p "dest/path"
mv "src/path/file1-copy.bin" "dest/path/file1-copy.bin"
mkdir -p "dest/path"
mv "src/path/file1-dup.bin" "dest/path/file1-dup.bin"

EOS

    string_io = StringIO.new
    capture_stdout(string_io) do
      processor.process_duplicates 'src/path/file1.bin' => ['src/path/file1-copy.bin', 'src/path/file1-dup.bin']
    end

    string_io.string.should == expected_script_content
  end

  it 'should generate bash script with multiple file sets' do
    processor = WriteBashScriptMoveDuplicatesProcessor.new(['src'], 'dest')

    expected_script_content = <<EOS
#!/bin/bash

# Duplicates of src/path/file1.bin
mkdir -p "dest/path"
mv "src/path/file1-copy.bin" "dest/path/file1-copy.bin"

# Duplicates of src/path/file2.bin
mkdir -p "dest/path"
mv "src/path/file2-copy.bin" "dest/path/file2-copy.bin"

EOS

    duplicates_hash = {
        'src/path/file1.bin' => ['src/path/file1-copy.bin'],
        'src/path/file2.bin' => ['src/path/file2-copy.bin'],
    }
    string_io = StringIO.new
    capture_stdout(string_io) do
      processor.process_duplicates(duplicates_hash)
    end

    string_io.string.should == expected_script_content
  end

  it 'should escape double quote in filename' do
    processor = WriteBashScriptMoveDuplicatesProcessor.new(['src'], 'dest')

    expected_script_content = <<EOS
#!/bin/bash

# Duplicates of src/a "funny" path/Karl's file.bin
mkdir -p "dest/a \"funny\" path"
mv "src/a \"funny\" path/Karl's file copy.bin" "dest/a \"funny\" path/Karl's file copy.bin"

EOS

    string_io = StringIO.new
    capture_stdout(string_io) do
      processor.process_duplicates %!src/a "funny" path/Karl's file.bin! => [%!src/a "funny" path/Karl's file copy.bin!]
    end

    string_io.string.should == expected_script_content
  end

end

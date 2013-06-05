require 'rspec'
require_relative '../../lib/duplicate_file_finder'

After do |scenario|
  @test_file_helper.delete_test_files
end

Given /^the following files in the directory '([^']+)'$/ do |dir_name, table|
  @test_dirs = [] if @test_dirs == nil
  @test_dirs << dir_name

  @test_file_helper = TestFileHelper.new
  table.hashes.each do |hash|
    @test_file_helper.create_test_file dir_name, hash
  end
end

When /^I execute the duplicate file finder$/ do
  @duplicate_file_sets = DuplicateFileFinder.new(FileInfo.new).find_duplicate_file_sets(@test_dirs)
end

Then /^I should get empty result$/ do
  @duplicate_file_sets.should be_empty
end

Then /^the result set should contain (\d+|no) file\-sets?$/ do |num_file_sets|
  file_sets_size = num_file_sets == 'no' ? 0 : Integer(num_file_sets)
  @duplicate_file_sets.size.should eq file_sets_size
end

Then /^file\-set (\d+) should contain the following$/ do |file_set_num, table|
  file_set_index = Integer(file_set_num) - 1
  expected_file_set = table.raw.map { |row| "#{row[0]}" }
  @duplicate_file_sets[file_set_index].should =~ expected_file_set
end

Then /^the file-sets should be as follows$/ do |table|
  @duplicate_file_sets.size.should == table.raw.size
  table.raw.each do |row|
    catch (:done) do
      @duplicate_file_sets.each do |file_set|
        throw :done if ( file_set.sort! == row.sort! )
      end
      fail 'Expected file set not found: ' + row.to_s
    end
  end
end
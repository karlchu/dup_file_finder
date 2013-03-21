require 'rspec'
require_relative '../../lib/duplicate_file_finder'

After do |scenario|
  @test_file_helper.delete_test_files
end

Given /^the following files in the directory '([^']+)'$/ do |dir_name, table|
  @test_dir = dir_name
  @test_file_helper = TestFileHelper.new
  table.hashes.each do |hash|
    @test_file_helper.create_test_file dir_name, hash
  end
end

When /^I execute the duplicate file finder$/ do
  @duplicate_file_sets = DuplicateFileFinder.new.find_duplicate_file_sets(@test_dir)
end

Then /^I should get empty result$/ do
  @duplicate_file_sets.should be_empty
end

Then /^the result set should contain (\d+) file\-set$/ do |num_file_sets|
  @duplicate_file_sets.size.should eq Integer(num_file_sets)
end

Then /^file\-set (\d+) should contains the following$/ do |file_set_num, table|
  file_set_index = Integer(file_set_num) - 1
  expected_file_set = table.raw.map { |row| "#{@test_dir}/#{row[0]}" }
  @duplicate_file_sets[file_set_index].should =~ expected_file_set
end
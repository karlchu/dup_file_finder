require 'rspec'
require 'minitest/unit'
require_relative '../lib/runtime_parameters'

describe RuntimeParameters do

  it 'should not be valid when no argument given' do
    runtime_parameters = RuntimeParameters.new
    runtime_parameters.parse([])

    runtime_parameters.valid?.should == false
  end

  it 'should indicate show help when -h short option given' do
    runtime_parameters = RuntimeParameters.new
    runtime_parameters.parse %w(-h)

    runtime_parameters.show_help?.should == true
  end

  it 'should indicate show help when --help long option given' do
    runtime_parameters = RuntimeParameters.new
    runtime_parameters.parse %w(--h)

    runtime_parameters.show_help?.should == true
  end

  it 'should parse destination folder option when -d option given' do
    runtime_parameters = RuntimeParameters.new
    runtime_parameters.parse %w(-d some/output/folder)

    runtime_parameters.destination.should == 'some/output/folder'
  end

  it 'should parse destination folder option when --dest long option given' do
    runtime_parameters = RuntimeParameters.new
    runtime_parameters.parse %w(--dest some/output/folder)

    runtime_parameters.destination.should == 'some/output/folder'
  end

  it 'should parse input folder' do
    runtime_parameters = RuntimeParameters.new

    runtime_parameters.parse %w(-d abc path/to/input/folder)

    runtime_parameters.input_folder.should == 'path/to/input/folder'
  end

  it 'should be valid when required info are given' do
    runtime_parameters = RuntimeParameters.new

    runtime_parameters.parse %w(-d abc path/to/input/folder)

    runtime_parameters.valid?.should == true
    runtime_parameters.show_help?.should == false
  end

  it 'should be invalid and show help when no input folder given' do
    runtime_parameters = RuntimeParameters.new

    runtime_parameters.parse %w(-d abc)

    runtime_parameters.valid?.should == false
    runtime_parameters.show_help?.should == true
  end

  it 'should be invalid and show help when no destination given' do
    runtime_parameters = RuntimeParameters.new

    runtime_parameters.parse %w(path/to/input)

    runtime_parameters.valid?.should == false
    runtime_parameters.show_help?.should == true
  end
end
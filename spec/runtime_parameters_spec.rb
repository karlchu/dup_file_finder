require 'rspec'
require 'minitest/unit'
require_relative '../lib/runtime_parameters'

describe RuntimeParameters do

  subject { RuntimeParameters.new }

  describe '#parse' do
    it 'should not be valid when no argument given' do
      subject.parse([])

      subject.valid?.should == false
    end

    it 'should be invalid and show help when no action given' do
      subject.parse %w(path/to/input)

      subject.valid?.should == false
      subject.show_help?.should == true
    end

    describe 'option for help' do
      it 'should indicate show help when -h short option given' do
        subject.parse %w(-h)

        subject.show_help?.should == true
      end

      it 'should indicate show help when --help long option given' do
        subject.parse %w(--h)

        subject.show_help?.should == true
      end
    end

    describe 'option for move' do
      it 'should parse destination folder option when -d option given' do
        subject.parse %w(-m some/output/folder)

        subject.destination.should == 'some/output/folder'
      end

      it 'should parse destination folder option when --dest long option given' do
        subject.parse %w(--move-to some/output/folder)

        subject.destination.should == 'some/output/folder'
      end

      it 'should parse input folder' do
        subject.parse %w(-m abc path/to/input/folder)

        subject.input_folders.should == ['path/to/input/folder']
      end

      it 'should not allow multiple input folders' do
        subject.parse %w(-m abc path/to/input1 path/to/input2)

        subject.valid?.should == false
        subject.show_help?.should == true
      end

      it 'should be valid when move destination is given' do
        subject.parse %w(-m abc path/to/input/folder)

        subject.valid?.should == true
        subject.show_help?.should == false
      end

      it 'should be invalid and show help when no input folder given' do
        subject.parse %w(-m abc)

        subject.valid?.should == false
        subject.show_help?.should == true
      end
    end

    describe 'option for delete' do
      it 'should parse delete long option' do
        subject.parse %w(--delete some/output/folder)

        subject.delete?.should == true
      end

      it 'should parse delete short option' do
        subject.parse %w(--delete some/output/folder)

        subject.delete?.should == true
      end

      it 'should be valid when delete short option is given' do
        subject.parse %w(-d path/to/input/folder)

        subject.valid?.should == true
        subject.show_help?.should == false
        subject.input_folders.should == ['path/to/input/folder']
      end

      it 'should parse multiple input folders' do
        subject.parse %w(-d path/to/input1 path/to/input2)

        subject.valid?.should == true
        subject.show_help?.should == false
        subject.input_folders.should == ['path/to/input1', 'path/to/input2']
      end
    end
  end
end

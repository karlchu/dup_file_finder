require 'ostruct'

class RuntimeParameters

  attr_reader :help_message

  def parse(args)
    @options = OpenStruct.new
    @options.show_help = false

    opts = define_option_parser()

    opts.parse!(args)

    @options.input_folders = args

    @help_message = opts.to_s

    if !valid?
      @options.show_help = true
    end
  end

  def define_option_parser
    OptionParser.new do |opts|
      opts.banner = 'Usage: ruby find_duplicates.rb [ -d | -m DESTINATION ] folder_to_scan'

      opts.on('-m', '--move-to', '=DESTINATION',
              'Move the duplicate files to the destination folder') do |dir|
        @options.destination = dir
      end

      opts.on('-d', '--delete',
              'Delete the duplicate files') do
        @options.delete = true
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        @options.show_help = true
      end
    end
  end

  def valid?
    return false if ( @options.destination.nil? && @options.delete.nil?)
    return false if @options.input_folders.empty?
    return false if ( @options.destination && @options.input_folders.size > 1 )
    true
  end

  def show_help?
    @options.show_help
  end

  def destination
    @options.destination
  end

  def input_folders
    @options.input_folders
  end

  def delete?
    @options.delete
  end
end

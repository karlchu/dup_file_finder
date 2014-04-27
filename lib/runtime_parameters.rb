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

    if @options.destination == nil || @options.input_folders.empty?
      @options.show_help = true
    end
  end

  def define_option_parser
    OptionParser.new do |opts|
      opts.banner = 'Usage: ruby find_duplicates.rb [options] folder_to_scan'

      opts.on('-M', '--move-to DESTINATION',
              'Destination folder to which to move duplicate files') do |dir|
        @options.destination = dir
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        @options.show_help = true
      end
    end
  end

  def valid?
    return false if @options.destination == nil
    return false if @options.input_folders.empty?
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


end

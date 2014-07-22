module Audiobank::Client
  class CLI

    attr_accessor :arguments

    def initialize(arguments = [])
      @arguments = arguments
    end

    attr_accessor :output
    def output
      @output ||= $stdout
    end

    def parser
      Trollop::Parser.new.tap do |parser|
        parser.version "AudioBank client v#{Audiobank::Client::VERSION}"
        parser.banner <<-EOS
Manage your AudioBank documents

Usage:
       audiobank [options] <command>

where <command> are:

    import <filenames>+ : to upload or import given files in AudioBank documents

where [options] are:
EOS

        parser.opt :debug, "Enable log messages"
        parser.opt :token, "Audiobank API token", :type => String
        parser.opt :base_uri, "Change default Audiobank url", :type => String
      end
    end

    def debug?
      options[:debug]
    end

    def init
      if debug?
        Audiobank::Client.logger = Logger.new($stderr)
      end

      account
    end

    def command
      arguments.shift
    end

    def run
      Trollop::with_standard_exception_handling(parser) do
        init
      end

      send command
    end

    def options
      @options ||= parser.parse(arguments).inject({}) do |map, pair|
        key, value = pair
        unless key == :help or key.to_s.match(/_given$/) or value.blank?
          map[key] = value
        end
        map
      end
    end

    def account
      Audiobank::Account.base_uri options[:base_uri] if options[:base_uri]

      if options[:token]
        Audiobank::Account.new(options[:token])
      else
        raise "No information to connect Audiobank account"
      end
    end

    def import
      arguments.each do |filename|
        unless filename =~ /.audiobank$/
          output.puts "Import #{filename}"
          Audiobank::Client::LocalFile.new(filename).import(account)
        end
      end
    end

  end
end

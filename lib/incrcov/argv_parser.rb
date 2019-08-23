require 'optparse'

Options = Struct.new(
  :old_commit,
  :new_commit,
  :format,
  :verbose,
  :diff_path
)

module Incrcov
  class ArgvParser
    def self.parse(options)
      args = Options.new

      args.old_commit = options[0]
      args.new_commit = options[1]

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: incrcov <commit> <commit> [options]"

        opts.on("-fFORMAT", "--format=FORMAT", "output format") do |v|
          args.format = v
        end

        opts.on("-v", "--verbose", "show verbose info") do |v|
          args.verbose = v
        end

        opts.on("-h", "--help", "show help info") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(options)
      args
    end
  end
end

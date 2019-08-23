require 'incrcov/diff_text_parser'
require 'incrcov/utils/io_util'
require 'incrcov/ruby_block_parser'

module Incrcov
  class IncrBlockAnalyzer
    class << self

      def analyze(diff)
        diff_result = DiffTextParser.parse(diff.patch)
        return if diff_result.new_file == '/dev/null'

        file_content = Utils::IoUtil.read_file(diff_result.new_file[2..-1])
        code_blocks = RubyBlockParser.parse(file_content)

        code_blocks.select do |block|
          updated?(block, diff_result)
        end
      end

      private

      def updated?(block, diff_result)
        diff_result.added_lines.each do |line|
          if block.first_line <= line && line <= block.last_line
            return true
          end
        end
        diff_result.removed_lines.each do |line|
          if block.first_line < line && line <= block.last_line
            return true
          end
        end
        false
      end
    end
  end
end

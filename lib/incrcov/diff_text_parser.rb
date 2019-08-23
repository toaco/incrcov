module Incrcov
  class DiffTextParser
    class << self
      def parse(diff_text)
        Incrcov.logger.debug "diff text: #{diff_text}"

        diff_result = DiffResult.new
        current_line = 0
        diff_text.lines.each do |line|
          if (result = /--- (.*)/.match(line))
            diff_result.old_file = result[1]
            next
          end

          if (result = /\+\+\+ (.*)/.match(line))
            diff_result.new_file = result[1]
            next
          end

          if (result = /@@ -\d+,?\d* \+(\d+),?\d* @@.*/.match(line))
            current_line = result[1].to_i
            if current_line == 0
              diff_result.removed_lines = [1]
              break
            else
              next
            end
          end

          if line.start_with?(' ')
            current_line += 1
          elsif line.start_with?('+')
            diff_result.added_lines << current_line
            current_line += 1
          elsif line.start_with?('-')
            diff_result.removed_lines << current_line
          end
        end

        Incrcov.logger.debug "diff result: #{diff_result}"
        diff_result
      end
    end
  end

  class DiffResult
    attr_accessor :old_file,
                  :new_file,
                  :added_lines,
                  :removed_lines

    def initialize
      self.added_lines = []
      self.removed_lines = []
    end

    def to_s
      self.inspect
    end
  end
end

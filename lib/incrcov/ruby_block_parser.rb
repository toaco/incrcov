require 'astrolabe/builder'
require 'parser/current'

module Incrcov
  class RubyBlockParser
    class << self
      def parse(code)
        source_buffer = Parser::Source::Buffer.new('incrcov')
        source_buffer.source = code
        ast_builder = Astrolabe::Builder.new
        parser = Parser::CurrentRuby.new(ast_builder)

        root_node = parser.parse(source_buffer)
        result = []
        root_node.each_node do |node|
          if node.type == :def
            func_name, = *node
            result << CodeBlock.new(func_name, node.loc.first_line, node.loc.last_line)
          end
        end
        result
      end
    end
  end

  class CodeBlock
    attr_accessor :name,
                  :first_line,
                  :last_line

    def initialize(name, first_line, last_line)
      self.name = name
      self.first_line = first_line
      self.last_line = last_line
    end

    def to_s
      "Name：#{@name}, Line number:#{@first_line}-#{@last_line}"
    end
  end
end

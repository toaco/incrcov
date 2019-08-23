require 'incrcov/version'
require 'incrcov/git_helper'
require 'incrcov/incr_block_analyzer'
require 'incrcov/simple_cov_json_parser'
require 'incrcov/config'
require 'incrcov/argv_parser'
require 'logger'
require 'terminal-table'
require 'markdown-tables'

module Incrcov
  class Error < StandardError
  end

  class << self
    attr_accessor :logger
    attr_accessor :config

    def run(argv)
      @config = ArgvParser.parse(argv)

      if config.verbose
        logger.level = Logger::INFO
      else
        logger.level = Logger::ERROR
      end

      output(incr_coverage_results)
    end

    private

    def incr_coverage_results
      git_helper = GitHelper.new('.')

      result = []
      git_helper.diff(config.old_commit, config.new_commit).each do |diff|
        begin
          next if diff.binary?
          path = diff.path
          next unless path =~ Config::INCLUDE_FILENAME_REGEX
          unless config.diff_path.nil?
            next if path.index(config.diff_path).nil?
          end

          logger.info "start to analyze file: #{path}"

          updated_blocks = IncrBlockAnalyzer.analyze(diff)
          next if updated_blocks.nil?

          coverage_json = SimpleCovJsonParser.parse('./coverage/.resultset.json')

          coverage_json['RSpec']['coverage'].each do |file, coverage|
            next unless file.end_with?(path)
            updated_blocks.each do |updated_block|
              result << incr_coverage_result(path, updated_block, coverage)
            end
          end
        rescue => e
          logger.error e
        end
      end

      result
    end

    # TODO: refactor
    def incr_coverage_result(path, updated_block, line_coverages)
      first_line = updated_block.first_line
      last_line = updated_block.last_line

      missed_lines = []
      line_coverages[(first_line - 1)..(last_line - 1)].each_with_index do |cover_times, index|
        if cover_times == 0
          line = first_line + index
          missed_lines << line
        end
      end

      coverage_lines = line_coverages[(first_line - 1)..(last_line - 1)].compact
      total = coverage_lines.count
      covered = coverage_lines.reject(&:zero?).count

      coverage_result = IncrCoverageResult.new
      coverage_result.path = "#{path}:#{first_line}"
      coverage_result.name = updated_block.name
      coverage_result.rate = covered.to_f / total
      coverage_result.covered = covered
      coverage_result.total = total
      coverage_result.missed_lines = missed_lines_text(missed_lines)

      coverage_result
    end

    # eg:
    # [1,2,3,5 7,9,10]  -> ['1-3','5', '7', '9-10']
    # [1]  -> ['1']
    # [1，2]  -> ['1-2']
    # []  -> []
    def missed_lines_text(missed_lines)
      return missed_lines if missed_lines.size <= 1
      result = []
      last_index = 0
      missed_lines[1..-1].each_with_index do |line, index|
        if line == missed_lines[index] + 1
          next
        elsif last_index == index
          result << missed_lines[index].to_s
          last_index += 1
        else
          result << "#{missed_lines[last_index]}-#{missed_lines[index]}"
          last_index = index + 1
        end
      end

      if last_index == missed_lines.size - 1
        result << missed_lines[-1].to_s
      else
        result << "#{missed_lines[last_index]}-#{missed_lines[-1]}"
      end

      result
    end

    def output(results)
      low_coverage_methods = results.select do |r|
        r.rate <= 0.9
      end

      if config.format == 'md' || config.format == 'markdown'
        markdown_output(results, low_coverage_methods)
      else
        default_output(results, low_coverage_methods)
      end
    end

    def default_output(results, low_coverage_methods)
      puts format_terminal_table(low_coverage_methods)
      total, covered = summary_info(results)
      rate = covered.to_f / total
      puts "Overall incremental test coverage: #{(rate * 100).round(2)}%"
      puts "Number of updated methods: #{results.count}"
      puts "Number of low test coverage(<90%) methods: #{low_coverage_methods.count}"
    end

    def markdown_output(results, low_coverage_methods)
      total, covered = summary_info(results)
      rate = covered.to_f / total

      if rate > 0.9
        emoji = '🎉'
      else
        emoji = '👀'
      end

      puts "### Merge Request Incremental Test Coverage Report #{emoji}

- Overall incremental test coverage: #{(rate * 100).round(2)}%
- Number of updated methods: #{results.count}
- Number of low test coverage(<90%) methods: #{low_coverage_methods.count}

---

#{format_markdown_table(low_coverage_methods)}"
    end

    def format_markdown_table(results)
      labels = ['Path', 'Method', 'Total Lines', 'Covered Lines', 'Coverage Rate', 'Missed Lines']
      data = []
      results.sort_by(&:rate).slice(0, 10).each do |r|
        data << [r.path, r.name, r.total, r.covered, "#{(r.rate * 100).round(2)}%", r.missed_lines.join(',')]
      end

      align = %w(l l l l)
      MarkdownTables.make_table(labels, data, is_rows: true, align: align)
    end

    def format_terminal_table(results)
      table = Terminal::Table.new headings: ['Path', 'Method', 'Total Lines', 'Covered Lines',
                                             'Coverage Rate', 'Missed Lines']
      results.sort_by(&:rate).slice(0, 10).each do |r|
        table << [r.path, r.name, r.total, r.covered, "#{(r.rate * 100).round(2)}%", r.missed_lines.join(',')]
      end
      table
    end

    def summary_row(results)
      total, covered = summary_info(results)
      rate = covered.to_f / total
      ['Total', '', total, covered, "#{(rate * 100).round(2)}%", '']
    end

    def summary_info(results)
      total = 0
      covered = 0
      results.each do |result|
        total += result.total
        covered += result.covered
      end
      [total, covered]
    end

  end

  class IncrCoverageResult
    attr_accessor :path,
                  :name,
                  :rate,
                  :missed_lines,
                  :covered,
                  :total
  end

  Incrcov.logger = Logger.new(STDOUT)
  Incrcov.logger.level = Logger::INFO
end

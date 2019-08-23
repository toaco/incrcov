require 'json'

module Incrcov
  class SimpleCovJsonParser
    class << self
      def parse(path)
        coverage_json = Utils::IoUtil.read_file(path)
        JSON.parse(coverage_json)
      end
    end
  end
end

module Incrcov
  module Utils
    class IoUtil
      class << self
        def read_file(file_name)
          File.open(file_name, 'r') do |file|
            data = file.read
            file.close
            return data
          end
        end
      end
    end
  end
end

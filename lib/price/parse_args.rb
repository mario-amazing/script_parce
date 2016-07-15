require 'optparse'

module GoodsPrice
  class ParserArgs
    def initialize(args)
      @args = args.dup
    end

    def parse
      OptionParser.new do |opts|
        opts.banner = 'Usage: from the root folder ./test/test.rb category_path file_name
                       http://www.viovet.co.uk/[category_path]'
      end.parse!(@args)
      category_path = @args.shift
      file_name = @args.shift.gsub(/.csv$/, '')
      validation_path(category_path)
      validation_file_name(file_name)
      {category_path: category_path, file_name: file_name}
    end

    def validation_path(path)
      if path.nil?
        raise "Wrong caterory path"
      end
    end

    def validation_file_name(file)
      if file.nil?
        raise "Wrong file name"
      end
    end
  end
end

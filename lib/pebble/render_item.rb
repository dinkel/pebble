module Pebble

  class RenderItem

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def read(indent = "")
      content = String.new
      IO.foreach(@path) do |line|
        content << indent
        content << line
      end
      content.chomp
    end

    def length
      @path.length
    end

  end

end

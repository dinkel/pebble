require 'pebble/render_item'

module Pebble

  class LayoutRenderItem < RenderItem

    def initialize(path, next_item)
      super(path)
      @next = next_item
    end
    
    def render(indent = "")
      content = String.new
      IO.foreach(@path) do |line|
        if line =~ /(.*)\{\{ content \}\}(.*)/
          unless @next.nil?        
            prepend = $1
            append = $2
            if (prepend =~ /^\s*$/) && (append =~ /^\s*$/)
              content << @next.render(indent + prepend) unless @next.nil?
              content << "\n"
            else
              content << "#{indent + prepend}"
              content << @next.render unless @next.nil?
              content << "#{append}\n"
            end
          else
            content << indent
            content << line
          end        
        else
          content << indent
          content << line
        end
      end
      content.chomp
    end

  end

end

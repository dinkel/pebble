module Pebble

  #--
  # RenderSeq class
  #++
  #
  # A *.html file has zero or more _layouts_, _slots_ and _snippets_ that are
  # rendered together. This class manages all of the parts that are rendered
  # for a single page of output.
  #
  class RenderSeq

    # Hashes of parts of pages that are to be rendered
    attr_accessor :layout, :snippets, :slots
    # 
    attr_reader :page

    # Set up a new RenderSeq. _page_ is 
    def initialize(page)
      @page = page
      @layout = nil
      @snippets = nil
      @slots = nil
      
      @content = String.new
    end
    
    def render
      render_layout
      render_page
      render_slots
      render_snippets
    end
    
    private
    
    def render_layout
      @content = @layout.render
    end
    
    def render_page
      content = String.new
      @content.each_line do |line|
        if line =~ /(.*)\{\{ content \}\}(.*)/
          prepend = $1
          append = $2
          if (prepend =~ /^\s*$/) && (append =~ /^\s*$/)
            content << @page.read(prepend)
            content << "\n"
          else
            content << "#{prepend}"
            content << @page.read
            content << "#{append}\n"
          end
        else
          content << line
        end
      end
      content.chomp
      @content = content
    end
    
    def render_slots
      content = String.new
      @content.each_line do |line|
        if line =~ /(.*)\{\{ content "(.*)" \}\}(.*)/
          prepend = $1
          slot = $2
          append = $3
          if (!@slots.nil?) && (@slots.has_key?(slot))
            if (prepend =~ /^\s*$/) && (append =~ /^\s*$/)
              content << @slots[slot].read(prepend)
              content << "\n"
            else
              content << "#{prepend}"
              content << @slots[slot].read
              content << "#{append}\n"
            end
          else
            $stderr.puts "WARNING: Slot with name '#{slot}' not found"
          end
        else
          content << line
        end
      end
      content.chomp
      @content = content
    end
    
    def render_snippets
      content = String.new
      @content.each_line do |line|
        if line =~ /(.*)\{\{ snippet "(.*)" \}\}(.*)/
          prepend = $1
          snippet = $2
          append = $3
          if (!@snippets.nil?) && (@snippets.has_key?(snippet))
            if (prepend =~ /^\s*$/) && (append =~ /^\s*$/)
              content << @snippets[snippet].read(prepend)
              content << "\n"
            else
              content << "#{prepend}"
              content << @snippets[snippet].read
              content << "#{append}\n"
            end
          else
            $stderr.puts "WARNING: Snippet with name '#{snippet}' not found"
          end
        else
          content << line
        end
      end
      content.chomp
      @content = content
    end
    
  end

end

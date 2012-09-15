module Pebble

  class Crawler

    attr_reader :pages, :layouts, :follow_layouts, :snippets, :slots, :static

    def initialize(root_path)
      @root = root_path

      @pages = Array.new
      @layouts = Array.new
      @follow_layouts = Array.new
      @snippets = Array.new
      @slots = Array.new
      @static = Array.new
      
      run
    end

    def run
      Find.find(@root) do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == ?.
            Find.prune       # Don't look any further into this directory.
          else
            next
          end
        elsif FileTest.file?(path)
          case File.basename(path)
            when /\..+\.layout$/
              @follow_layouts << path
            when /\.layout$/
              @layouts << path
            when /\.snippet$/
              @snippets << path
            when /\..+\.html$/
              @slots << path
            when /\.html$/
              @pages << path
            else
              @static << path
          end
        end
      end
    end
    
  end

end

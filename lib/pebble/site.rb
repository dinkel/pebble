require 'fileutils'

module Pebble

  class Site

    # The current value of the directory tree to be rendered 
    attr_reader :site_root
    
    # The current value of where to save the rendered site
    attr_reader :rendered_root

    def initialize(site_root, rendered_root)
      @site_root = site_root
      @rendered_root = rendered_root
      @sequences = Array.new    
    end
    
    # Add a RenderSeq to Site that needs to be rendered
    def add_sequence(seq)
      @sequences << seq
    end
    
    # Iterates over every RenderSeq and calls it to render itself
    def render
      @sequences.each do |seq|
        target = get_and_prepare_target(seq.page.path)
        content = seq.render
        File.open(target, "w") do |file|
          file.puts content
        end
      end
      
    end
    
    # Checks and possibly deletes everything that is at the location
    # of _rendered_root_ where the new rendered site goes.
    # If _force_ is set to +true+, no question is asked if the directory
    # already exists.
    def clean_target(force = false)
      if File.exists?(@rendered_root)
        unless force
          print "Are you sure to overwrite directory '#{@rendered_root}' [yN] ? "
          exit unless $stdin.gets.chomp.downcase == 'y'
        end
        FileUtils.rm_r(@rendered_root, :secure => true)
      end
    end

    # Copies the static files to the destination
    def copy_static(files)
    
      files.each do |file|
        target = get_and_prepare_target(file)
        FileUtils.cp(file, target)
      end
              
    end
    
    private
    
    def get_and_prepare_target(source)
      filename = source.sub(@site_root, @rendered_root)
      dirname = File.dirname(filename)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      filename
    end

  end

end

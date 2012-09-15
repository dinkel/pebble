require 'cli'

module Pebble

  class CliParser
  
    def initialize(arguments = ARGV)
    
      @options = CLI.new do
        version(Pebble::VERSION)
        switch(:force, {:short => :f, :description => 'Overwrites "dst-dir" without asking'})
        argument(:src_dir, {:required => false, :description => 'Current working directory is taken if omitted'})
        argument(:dst_dir, {:required => false, :description => 'Name of "src-dir" prefixed with "rendered_" if omitted'})
      end.parse!(arguments)

    end

    def force
      !@options.force.nil?
    end
  
    def src_dir
      if (@options.src_dir)
        File.expand_path(@options.src_dir)
      else
        Dir.pwd
      end
    end

    def dst_dir
      if (@options.dst_dir)
        File.expand_path(@options.dst_dir)
      else
        File.join(File.dirname(src_dir), 'rendered_' + File.basename(src_dir))
      end
    end
  
  end

end

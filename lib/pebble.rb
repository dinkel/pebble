#--
# Copyright (c) 2007, Christian Luginbuehl
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * No names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#++
#
# = Pebble -- Simple static CMS
#      
# This is the main file for the Pebble application.  Normally it is referenced
# as a library via a require statement and invoked using the +pebble+ 
# executable.

require 'find'
require 'fileutils'
require 'pebble/site'
require 'pebble/cli_parser'
require 'pebble/crawler'
require 'pebble/render_item'
require 'pebble/layout_render_item'
require 'pebble/render_seq'
require 'pebble/version'

###############################################################################
# Some extensions to Dir
#
class Dir

  # Recursively delete a directory tree including files (like rm -rf)
  def Dir.rmdir_rec(dir)
    Dir.foreach(dir) do |e|
      next if [".", ".."].include? e
      fullname = dir + File::Separator + e
      if FileTest::directory?(fullname)
        Dir.rmdir_rec(fullname)
      else
        File.delete(fullname)
      end
    end
    Dir.delete(dir)
  end

  # Recursively create directories (like mkdir -p)
  def Dir.mkdir_rec(dir)
    parent = File.expand_path(File.join(dir, ".."))
    Dir.mkdir_rec(File.expand_path(File.join(dir, ".."))) unless File.directory?(parent)
    Dir.mkdir(dir)
  end

end

##############################################################################
# Pebble module
#
module Pebble

  # Pebble module singleton methods.
  #
  class << self
    # Current Pebble Application
    def application
      @application ||= Pebble::Application.new
    end
  end

  class Application
  
    def initialize
      parser = CliParser.new()
      
      @force = parser.force
      @src = parser.src_dir
      @dst = parser.dst_dir
    end
  
    # Runs *pebble* by first putting together all RenderSeq's, preparing the
    # destination directory and then rendering and saving the files. As its
    # last step, all the static files are copied to the destination.
    def run
      @crawler = Crawler.new(@src)
      
      @site = Site.new(@src, @dst)
      
      find_render_sequences
      
      @site.clean_target(@force)
      @site.render
      @site.copy_static(@crawler.static)

    end

    private
    
    # Find the render sequences for every page to be rendered
    def find_render_sequences
      @crawler.pages.each do |path|

        page = RenderItem.new(path)
        
        seq = RenderSeq.new(page)

        filename = File.basename(path, ".html")
        dirname = File.dirname(path)

        # search in local dir for [filename].layout
        if @crawler.layouts.include?(File.join(dirname, "#{filename}.layout"))
          item = LayoutRenderItem.new(File.join(dirname, "#{filename}.layout"), nil)
          seq.layout = item
        end

        # search in local dir for [filename].follow.layout
        if seq.layout.nil? && @crawler.follow_layouts.include?(File.join(dirname, "#{filename}.follow.layout"))
          item = LayoutRenderItem.new(File.join(dirname, "#{filename}.follow.layout"), item)
        end

        # search in local dir for default.layout
        if seq.layout.nil? && @crawler.layouts.include?(File.join(dirname, "default.layout"))
          item = LayoutRenderItem.new(File.join(dirname, "default.layout"), item)
          seq.layout = item
        end

        # search in local dir for default.follow.layout
        if seq.layout.nil? && @crawler.follow_layouts.include?(File.join(dirname, "default.follow.layout"))
          item = LayoutRenderItem.new(File.join(dirname, "default.follow.layout"), item)
        end

        if seq.layout.nil?
          # search in parents for default.layout
          possible_layouts = Array.new
          @crawler.layouts.each do |layout|
            if (layout =~ /default\.layout$/) && (dirname.include? File.dirname(layout))
              possible_layouts << layout
            end
          end
        
          possible_layouts.sort { |a, b| b.length <=> a.length }
          
          # search in parents for default.follow.layout
          possible_follow_layouts = Array.new
          @crawler.follow_layouts.each do |layout|
            if (layout =~ /default\.follow\.layout$/) && (dirname.include? File.dirname(layout)) && (!File.dirname(layout).include? dirname)
              possible_follow_layouts << layout
            end
          end
          
          possible_follow_layouts.sort { |a, b| b.length <=> a.length }

          possible_follow_layouts.each do |layout|
            if layout.length - 7 > possible_layouts[0].length
              item = LayoutRenderItem.new(layout, item)
            end
          end

          item = LayoutRenderItem.new(possible_layouts[0], item) unless possible_layouts.empty?

        end
        
        seq.layout = item if seq.layout.nil?
        
        # search for all possible snippets (in case of same name, higher level will be ignored)
        possible_snippets = Hash.new
        @crawler.snippets.each do |snippet|
          if dirname.include? File.dirname(snippet)
            name = File.basename(snippet, ".snippet")
            if (!possible_snippets.has_key?(name)) || (possible_snippets[name].length < snippet.length)
              possible_snippets[name] = RenderItem.new(snippet)
            end
          end
        end

        seq.snippets = possible_snippets

        # search for all possible slots (in case of 'default' and specific name, the latter is used)
        possible_slots = Hash.new
        @crawler.slots.each do |slot|
          if dirname.eql? File.dirname(slot)
            if File.basename(slot, ".html").include? filename
              name = File.basename(slot, ".html").sub("#{filename}.", '')
              possible_slots[name] = RenderItem.new(slot)
            elsif File.basename(slot, ".html").include? 'default'
              name = File.basename(slot, ".html").sub("default.", '')
              possible_slots[name] = RenderItem.new(slot)
            end
          end
        end

        seq.slots = possible_slots
        
        @site.add_sequence(seq)
      end
    end

  end
  
end

require 'test/unit'
require 'pebble/crawler'

class CrawlerTest < Test::Unit::TestCase

  def setup
    @directory = File.dirname(__FILE__)
  end

  def test_before_below_test_this_directory
    crawler = Pebble::Crawler.new(@directory)
    
    assert_equal(crawler.static, [__FILE__])
    assert_equal(crawler.pages, [])
  end

  def test_layout_file
    File.new(File.join(@directory, 'test.layout'), 'w')
    crawler = Pebble::Crawler.new(@directory)
    
    assert_equal(crawler.layouts.size, 1)
    
    File.unlink(File.join(@directory, 'test.layout'))
  end

  def test_pages_file
    File.new(File.join(@directory, 'test.html'), 'w')
    crawler = Pebble::Crawler.new(@directory)
    
    assert_equal(crawler.pages.size, 1)
    
    File.unlink(File.join(@directory, 'test.html'))
  end

end

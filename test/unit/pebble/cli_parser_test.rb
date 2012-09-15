require 'test/unit'
require 'pebble/cli_parser'

class CliParserTest < Test::Unit::TestCase

  def test_no_force_switch
    parser = Pebble::CliParser.new([])
    
    assert_equal(false, parser.force)
  end
  
  def test_force_switch_long
    parser = Pebble::CliParser.new(['--force'])
    
    assert_equal(true, parser.force)
  end

  def test_force_switch_short
    parser = Pebble::CliParser.new(['-f'])
    
    assert_equal(true, parser.force)
  end

  def test_no_explicit_dirs
    parser = Pebble::CliParser.new([])

    assert_equal(File.expand_path(Dir.pwd), parser.src_dir)

    dst_dir = File.join(File.dirname(Dir.pwd), 
                        'rendered_' + File.basename(Dir.pwd))

    assert_equal(File.expand_path(dst_dir), parser.dst_dir)
  end

  def test_absolute_explicit_src_dir
    parser = Pebble::CliParser.new(['/pebble/test'])

    assert_equal('/pebble/test', parser.src_dir)
    assert_equal('/pebble/rendered_test', parser.dst_dir)
  end
  
  def test_relative_explicit_src_dir
    parser = Pebble::CliParser.new(['..'])

    src_dir = File.expand_path(File.join(Dir.pwd, '..'))

    assert_equal(src_dir, parser.src_dir)
  end
  
  def test_absolute_explicit_src_and_dst_dir
    parser = Pebble::CliParser.new(['/pebble/test', '/pebble/publish'])

    assert_equal('/pebble/test', parser.src_dir)
    assert_equal('/pebble/publish', parser.dst_dir)
  end
  
end

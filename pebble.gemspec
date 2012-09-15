require 'date'

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'pebble/version'

Gem::Specification.new do |s|
  s.name        = 'pebble'
  s.version     = Pebble::VERSION
  s.date        = Date.today
  s.summary     = 'Pebble'
  s.description = 'A simple static CMS'
  s.author      = 'Christian Luginbuehl'
  s.email       = 'dinkel@pimprecords.com'
#  s.homepage    = 'http://dinkel.pimprecords.com/pebble/'
  s.files       = Dir['lib/**/*.rb']
#  s.require_path  =   "lib"
#  s.autorequire   =   "pebble"
#  s.has_rdoc = true
#  s.extra_rdoc_files  =   ["README"]
#  s.bindir = "bin"
#  s.executables = ["pebble"]
  s.executables << 'pebble'
  s.add_runtime_dependency "cli", "~> 1.1"
end


$:.unshift('/Library/RubyMotion/lib')

ENV['platform'] = 'osx'
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
# ignored
end

Motion::Project::App.setup do |app|
  app.name       = 'motion-paddle'
  app.identifier = 'us.myepg.motion-paddle'
  app.specs_dir  = 'spec/'
end
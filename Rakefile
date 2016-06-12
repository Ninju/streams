require "rubygems"
require "rake"
require "echoe"

Echoe.new( "streams", "1.0" ) do | p |
  p.description = ""
  p.url = "http://github.com/Ninju/streams"
  p.author = "Alex Watt"
  p.email = "alex.watt@me.com"
  p.ignore_pattern = []
  p.development_dependencies = []
end

task :default => "spec:run"

namespace :spec do
  task :run do
    system( "rspec spec/" )
  end

  task :doc do
    system( "rspec spec/ --format specdoc" )
  end

  task :coverage do
    system( "rcov spec/*_spec.rb" )
    system( "open coverage/index.html" )
  end
end

task :spec => "spec:run"

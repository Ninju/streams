task :default => "spec:run"

namespace :spec do
  task :run do
    system( "spec spec/" )
  end

  task :doc do
    system( "spec spec/ --format specdoc" )
  end

  task :coverage do
    system( "rcov spec/*_spec.rb" )
    system( "open coverage/index.html" )
  end
end

task :spec => "spec:run"

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{streams}
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Watt"]
  s.date = %q{2009-02-12}
  s.description = %q{}
  s.email = %q{alex.watt@me.com}
  s.extra_rdoc_files = ["lib/streams.rb", "README"]
  s.files = ["lib/streams.rb", "Rakefile", "README", "spec/spec_helper.rb", "spec/streams_spec.rb", "Manifest", "streams.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Ninju/streams}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Streams", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{streams}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lightcsv}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["\343\201\250\343\201\277\343\201\237\343\201\276\343\201\225\343\201\262\343\202\215 <tommy@tmtm.org>"]
  s.date = %q{2009-07-27}
  s.description = %q{A pure Ruby CSV parser wrapped into a gem version for easier install.}
  s.email = %q{}
  s.extra_rdoc_files = ["README.txt", "lib/lightcsv.rb"]
  s.files = ["README.txt", "setup.rb", "test/test_lightcsv.rb", "lib/lightcsv.rb", "Makefile", "Rakefile", "Manifest", "lightcsv.gemspec"]
  s.homepage = %q{http://www.tmtm.org/ruby/lightcsv/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Lightcsv", "--main", "README.txt", "--charset", "utf-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lightcsv}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A pure Ruby CSV parser}
  s.test_files = ["test/test_lightcsv.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

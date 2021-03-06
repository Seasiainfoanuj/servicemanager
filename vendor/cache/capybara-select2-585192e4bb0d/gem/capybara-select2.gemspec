# -*- encoding: utf-8 -*-
# stub: capybara-select2 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "capybara-select2".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["William Yeung".freeze]
  s.date = "2019-01-17"
  s.description = "Helper for triggering select for select2 javascript library".freeze
  s.email = ["william@tofugear.com".freeze]
  s.files = ["Gemfile".freeze, "Rakefile".freeze, "capybara-select2.gemspec".freeze, "lib/capybara-select2.rb".freeze, "lib/capybara-select2/version.rb".freeze, "lib/capybara/select2.rb".freeze, "lib/capybara/selectors/tag_selector.rb".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "2.7.8".freeze
  s.summary = "".freeze

  s.installed_by_version = "2.7.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<capybara>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
  end
end

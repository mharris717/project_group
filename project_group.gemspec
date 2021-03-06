# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: project_group 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "project_group"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mike Harris"]
  s.date = "2014-09-06"
  s.description = "project_group"
  s.email = "mharris717@gmail.com"
  s.executables = ["proj"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "Guardfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/proj",
    "lib/project_group.rb",
    "lib/project_group/command.rb",
    "lib/project_group/config.rb",
    "lib/project_group/ext/string_ext.rb",
    "lib/project_group/git_tasks.rb",
    "lib/project_group/group.rb",
    "lib/project_group/plugin.rb",
    "lib/project_group/reach.rb",
    "lib/project_group/repo.rb",
    "lib/project_group/run_tests.rb",
    "lib/project_group/single.rb",
    "lib/project_group/sublime_project.rb",
    "project_group.gemspec",
    "spec/command_spec.rb",
    "spec/config_spec.rb",
    "spec/group_spec.rb",
    "spec/plugin_spec.rb",
    "spec/project_group_spec.rb",
    "spec/repo_spec.rb",
    "spec/run_tests_spec.rb",
    "spec/spec_helper.rb",
    "spec/sublime_project_spec.rb",
    "spec/support/config.rb",
    "spec/support/ec.rb",
    "spec/support/make_initial.rb",
    "tags",
    "tags.old",
    "vol/deps.inspect",
    "vol/full_deps.inspect",
    "vol/grit_diff.rb",
    "vol/mock_deps.rb",
    "vol/pipe_test.rb",
    "vol/shell_test.rb",
    "vol/test/.project_group.rb"
  ]
  s.homepage = "http://github.com/mharris717/project_group"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "project_group"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mharris_ext>, [">= 0"])
      s.add_runtime_dependency(%q<andand>, [">= 0"])
      s.add_runtime_dependency(%q<grit>, [">= 0"])
      s.add_runtime_dependency(%q<mongoid_gem_config>, [">= 0"])
      s.add_runtime_dependency(%q<remote_cache>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-spork>, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_development_dependency(%q<lre>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
    else
      s.add_dependency(%q<mharris_ext>, [">= 0"])
      s.add_dependency(%q<andand>, [">= 0"])
      s.add_dependency(%q<grit>, [">= 0"])
      s.add_dependency(%q<mongoid_gem_config>, [">= 0"])
      s.add_dependency(%q<remote_cache>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-spork>, [">= 0"])
      s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_dependency(%q<lre>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
    end
  else
    s.add_dependency(%q<mharris_ext>, [">= 0"])
    s.add_dependency(%q<andand>, [">= 0"])
    s.add_dependency(%q<grit>, [">= 0"])
    s.add_dependency(%q<mongoid_gem_config>, [">= 0"])
    s.add_dependency(%q<remote_cache>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-spork>, [">= 0"])
    s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
    s.add_dependency(%q<lre>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
  end
end


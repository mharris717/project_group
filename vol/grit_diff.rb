require 'grit'
require 'mharris_ext'

load "lib/project_group.rb"

repo = ProjectGroup::Repo.new(path: "/code/orig/game_store")
puts repo.only_gemspec_date_change?





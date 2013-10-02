require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Sublime Project' do
  let(:group) do
    res = ProjectGroup::Group.new
    res << "/code/orig/ezq"
    res << "/code/orig/fat_secret"
    res
  end

  let(:sublime_project) do
    ProjectGroup::SublimeProject.new(:group => group)
  end

  it 'smoke' do
    str = sublime_project.to_json
    #File.create "/code/orig/project_group/ezq.sublime-project",str
  end
end
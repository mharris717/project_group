require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ProjectGroup::Group" do
  include_context "project"

  project "foo" do
    create "a.txt"
    push
  end

  project "bar" do
    create "a.txt"
    File.create "b.txt","zzz"
  end

  it 'uncommitted files' do
    group.uncommitted_files.size.should == 1
  end

  it 'doesnt need push' do
    group.should be_needs_push
  end

  it 'projects size' do
    group.singles.size.should == 2
  end
end

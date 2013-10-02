require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ProjectGroup::Group" do
  describe "basic" do
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

  if false
  describe "load from file" do
    include_context "project"

    project "foo" do
      create "a.txt"
      push
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    before(:all) do
      str = "abc"
      File.create "#{MakeInitial.tmp_dir}/groups/ezq.rb", str
    end

    let(:group) do
      ProjectGroup::Group.load_by_name("ezq")
    end

    it 'smoke' do
      group.singles.size.should == 2
    end
  end
  end
end

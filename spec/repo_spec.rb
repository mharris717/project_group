require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "Repo" do
  describe "basic" do
    include_context "project"
    project do
      create "a.txt"
    end

    it 'changed files' do
      proj.uncommitted_files.size.should == 0
    end
  end

  describe "changed files" do
    include_context "project"
    project do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    it 'changed files' do
      proj.uncommitted_files.size.should == 1
    end
  end

  describe "pushed" do
    include_context "project"
    project do
      make_remote
      create "a.txt"
      push
    end

    it 'pushed' do
      proj.should_not be_needs_push
    end
  end

  describe "not pushed" do
    include_context "project"
    project do
      make_remote
      create "a.txt"
      push
      create "b.txt"
    end

    it 'pushed' do
      proj.should be_needs_push
    end
  end

  describe "not pushed - no origin/master" do
    include_context "project"
    project do
      make_remote
      create "a.txt"
    end

    it 'pushed' do
      proj.should be_needs_push
    end
  end


end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "Repo" do
  it "smoke" do
    2.should == 2
  end

  before(:all) do
    MakeInitial.make do
      project "foo" do
        create "a.txt"
      end

      project "bar" do
        create "a.txt"
        File.create "b.txt","zzz"
      end
    end
  end

  let(:foo) do
    dir = File.expand_path(File.dirname(__FILE__) + "/../tmp/projects/foo")
    ProjectGroup::Single.new(:path => dir)
  end

  let(:bar) do
    dir = File.expand_path(File.dirname(__FILE__) + "/../tmp/projects/bar")
    ProjectGroup::Single.new(:path => dir)
  end

  it 'changed files' do
    foo.uncommitted_files.size.should == 0
  end

  it 'changed files 2' do
    bar.uncommitted_files.tap do |a|
      a.size.should == 1
      a.first.relative_path.should == "b.txt"
    end
  end

  it 'push' do
    foo.should be_needs_push
  end
end

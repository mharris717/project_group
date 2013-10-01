require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "ProjectGroup::Group" do
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

  let(:group) do
    dir = File.expand_path(File.dirname(__FILE__) + "/../tmp/projects")
    res = ProjectGroup::Group.new
    res << "#{dir}/foo"
    res << "#{dir}/bar"
    res
  end

  it 'uncommitted files' do
    group.uncommitted_files.size.should == 1
  end
end

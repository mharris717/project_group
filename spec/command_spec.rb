require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "Command" do
  it "smoke" do
    2.should == 2
  end

  describe "cycle with name" do
    let(:full_command) do
      "cycle -n ezq"
    end
    let(:command) do
      res = ProjectGroup::Command.new
      res.parse! full_command.split(" ")
      res
    end

    it 'group name' do
      command.group_name.should == 'ezq'
    end

    it 'cmd' do
      command.cmd.should == 'cycle'
    end
  end


end

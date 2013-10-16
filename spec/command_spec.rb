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

  describe "basic" do
    include_context "project"
    let(:should_setup_file_system) { false }

    project "foo" do
      create "a.txt"
      push
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    let(:command) do
      res = ProjectGroup::Command.new
      res.configs = ProjectGroup::Configs.new(:groups => [group])
      res.parse! full_command.split(" ")
      res
    end

    let(:full_command) do
      "cycle -n abc"
    end

    it 'group name' do
      command.group.name.should == 'abc'
    end

    it 'singles' do
      command.singles.map { |x| x.short_name }.sort.should == ['foo','bar'].sort
    end
  end

  describe "works on project" do
    include_context "project"
    let(:should_setup_file_system) { false }

    project "foo" do
      create "a.txt"
      push
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    let(:command) do
      res = ProjectGroup::Command.new
      res.configs = ProjectGroup::Configs.new(:groups => [group])
      res.parse! full_command.split(" ")
      res
    end

    let(:full_command) do
      "cycle -p foo"
    end

    it 'singles' do
      command.dir = singles.first.path
      command.singles.map { |x| x.short_name }.should == ['foo']
    end
  end

  describe "only gives one single when in project dir" do
    include_context "project"
    let(:should_setup_file_system) { false }

    project "foo" do
      create "a.txt"
      push
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    let(:command) do
      res = ProjectGroup::Command.new
      res.configs = ProjectGroup::Configs.new(:groups => [group])
      res.dir = singles.first.path
      res.parse! full_command.split(" ")
      res
    end

    let(:full_command) do
      "cycle"
    end

    it 'singles' do
      command.singles.map { |x| x.short_name }.should == ['foo']
    end
  end

  describe "group flag" do
    include_context "project"
    let(:should_setup_file_system) { false }

    project "foo" do
      create "a.txt"
      push
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end

    let(:command) do
      res = ProjectGroup::Command.new
      res.configs = ProjectGroup::Configs.new(:groups => [group])
      res.dir = singles.first.path
      res.parse! full_command.split(" ")
      res
    end

    let(:full_command) do
      "cycle -g"
    end

    it 'singles' do
      command.singles.map { |x| x.short_name }.should == ['foo','bar']
    end
  end

end

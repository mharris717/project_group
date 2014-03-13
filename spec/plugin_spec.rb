require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_context "plugin" do
  let(:config_body) do
    'ProjectGroup::Configs.group "ezq" do |g|
      g.project "ezq" do |p|
        p.path "/code/orig/ezq"
      end
      g.project "ezq2" do |p|
        p.path "/code/orig/ezq2"
      end
    end'
  end
  let(:working_dir) { "/nowhere" }
  let(:plugin_ops) { {} }
  def setup_plugin
    ProjectGroup::Plugins.instance!
    ProjectGroup.register_plugin(:thing,plugin_ops) do |p|
      $thing_names << p.short_name
    end
    $thing_names = []
  end
  let(:command) do
    res = ProjectGroup::Command.new(:configs => configs, :dir => working_dir)
    res.parse! full_command.split(" ")
    res
  end
  before do
    setup_plugin
  end
end

describe "Plugin" do
  describe "cycle with name" do
    include_context "config"
    include_context "plugin"

    describe "specify name" do
      let(:full_command) do
        "thing -n ezq"
      end
      
      it 'group name' do
        command.group_name.should == 'ezq'
      end

      it 'cmd' do
        command.cmd.should == 'thing'
      end

      it 'singles' do
        command.singles.size.should == 2
      end

      it 'run' do
        command.run!
        $thing_names.should == ['ezq','ezq2']
      end
    end

    describe "no name, with working dir" do
      before do
        command.dir = "/code/orig/ezq"
      end
      let(:full_command) do
        "thing"
      end

      it 'run' do
        command.run!
        $thing_names.should == ['ezq']
      end
    end

    describe "no name, with working dir, group flag" do
      before do
        command.dir = "/code/orig/ezq"
      end
      let(:full_command) do
        "thing -g"
      end

      it 'run' do
        command.run!
        $thing_names.should == ['ezq','ezq2']
      end
    end

    describe "no name, with working dir, plugin set to group mode" do
      let(:plugin_ops) do
        {use_group: true}
      end
      before do
        command.dir = "/code/orig/ezq"
      end
      let(:full_command) do
        "thing"
      end

      it 'run' do
        command.run!
        $thing_names.should == ['ezq','ezq2']
      end
    end

    
  end
end
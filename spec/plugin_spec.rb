require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "Plugin" do
  it "smoke" do
    2.should == 2
  end

  describe "cycle with name" do
    include_context "config"
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

    before do
      ProjectGroup::Plugins.instance!
      ProjectGroup.register(:thing) do |p|
        $thing_names << p.short_name
      end
      $thing_names = []
    end
    let(:full_command) do
      "thing -n ezq"
    end
    let(:command) do
      res = ProjectGroup::Command.new(:configs => configs)
      res.parse! full_command.split(" ")
      res
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
end
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_context "config" do
  let(:configs) do
    ProjectGroup::Configs.instance
  end
  let(:local_config_body) { "" }
  let(:config_body) { "" }
  before(:all) do
    File.create("#{MakeInitial.tmp_dir}/configs/ezq.rb", config_body)
    File.create("#{MakeInitial.tmp_dir}/tmp1/.project_group.rb", local_config_body) 

    Dir.chdir("#{MakeInitial.tmp_dir}/tmp1") do
      c = ProjectGroup::Configs.instance!
      c.dir = "#{MakeInitial.tmp_dir}/configs"
      c.load!
    end
  end

  let(:group_config) do
    configs.group_configs.first
  end
  let(:group) do
    configs.groups.first
  end
  let(:project) do
    configs.projects.first
  end
end

describe "ProjectGroup::Config" do
  describe 'single project' do
    include_context "config"
    let(:config_body) do
      'ProjectGroup::Configs.project "ezq" do |p|
         p.path "abc"
      end'
    end
    
    it 'created something' do
      configs.projects.size.should == 1
    end

    it 'name' do
      project.name.should == 'ezq'
    end

    it 'path' do
      project.path.should == 'abc'
    end
  end

  describe "two projects and a group" do
    include_context "config"
    let(:config_body) do
      'ProjectGroup::Configs.project "ezq" do |p|
        p.path "/code/orig/ezq"
      end

      ProjectGroup::Configs.project "ezqweb" do |p|
        p.path "/code/orig/ezqweb"
      end

      ProjectGroup::Configs.group "ezq" do |p|
        p.project "ezq"
        p.project "ezqweb"
      end'
    end

    it 'projects count' do
      configs.projects.size.should == 2
    end

    it 'groups count' do
      configs.groups.count.should == 1
      configs.group_configs.count.should == 1
    end

    it 'group project names' do
      group_config.project_names.sort.should == %w(ezq ezqweb).sort
    end

    it 'group projects' do
      group.singles.map { |x| x.path }.sort.should == ["/code/orig/ezq","/code/orig/ezqweb"].sort
    end

    it 'group projects name' do
      group.singles.map { |x| x.name }.sort.should == %w(ezq ezqweb).sort
    end
  end

  describe "inline project" do
    include_context "config"
    let(:config_body) do
      'ProjectGroup::Configs.group "ezq" do |g|
        g.project "ezq" do |p|
          p.path "/code/orig/ezq"
        end
      end'
    end

    it 'project path' do
      group.singles.map { |x| x.path }.should == ['/code/orig/ezq']
    end
  end

  describe "local project file" do
    include_context "config"
    let(:local_config_body) do
      'ProjectGroup::Configs.group "ezq" do |g|
        g.project "ezq" do |p|
          p.path "/code/orig/ezq"
        end
      end'
    end

    it 'projects count' do
      configs.projects.size.should == 1
    end

    it 'local group' do
      configs.local_group.name.should == 'ezq'
    end
  end

end
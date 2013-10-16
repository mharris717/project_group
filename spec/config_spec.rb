require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Object
  def safe
    Safe.new(:base => self)
  end
end

class Safe
  include FromHash
  attr_accessor :base

  def method_missing(sym,*args,&b)
    res = base.send(sym,*args,&b)
    raise "nil return for #{sym} #{args.inspect}" unless res
    res
  end
end

describe "ProjectGroup::Config" do
  describe 'single project' do
    include_context "config"
    let(:config_body) do
      'ProjectGroup::Configs.project "ezq" do |p|
         p.path "abc"
         p.type :eak
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

    it 'name has group prefix' do
      group.singles.first.name.should == "ezq-ezq"
    end
  end

  describe "current dir group" do
    include_context "config"
    include_context "project"

    project "foo" do
      create "a.txt"
    end

    project "bar" do
      create "a.txt"
    end

    let(:config_body) do
      "ProjectGroup::Configs.group 'ezq' do |g|
        g.project 'ezq' do |p|
          p.path '#{MakeInitial.tmp_dir}/projects/foo'
        end
      end

      ProjectGroup::Configs.group 'thing' do |g|
        g.project 'other' do |p|
          p.path '#{MakeInitial.tmp_dir}/projects/bar'
        end
      end"
    end

    it 'dir' do
      dir = "#{MakeInitial.tmp_dir}/projects/foo"
      ProjectGroup::Configs.loaded.safe.group_for_dir(dir).name.should == 'ezq'
    end

    it 'bar' do
      dir = "#{MakeInitial.tmp_dir}/projects/bar"
      ProjectGroup::Configs.loaded.group_for_dir(dir).name.should == 'thing'
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
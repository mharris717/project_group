module ProjectGroup
  class DSLWrapper
    include FromHash
    attr_accessor :obj
    def initialize(obj)
      @obj = obj
    end
    def method_missing(sym,*args,&b)
      if args.empty?
        obj.send sym
      else
        obj.send "#{sym}=",args.first
      end
    end
  end

  class GroupWrapper < DSLWrapper
    fattr(:project_names) { [] }
    attr_accessor :configs
    attr_accessor :local

    def singles
      project_names.map do |name|
        configs.projects.find { |x| x.name == name }
      end
    end
    fattr(:loaded_group) do
      obj.singles = singles
      obj
    end
    def project(name,&b)
      self.project_names << name
      if block_given?
        configs.project(name,&b)
      end
    end
    def name(name)
    end
  end

  class Configs
    fattr(:dir) do
      File.expand_path("~/.project_group")
    end
    def load!
      Dir["#{dir}/*.rb"].each do |f|
        load f
      end
      global_groups = group_configs.clone

      locals = ["#{Dir.getwd}/.project_group.rb","#{Dir.getwd}/.project_group"]
      locals.each do |f|
        if FileTest.exist?(f)
          load(f) 
          local_groups = group_configs - global_groups
          local_groups.first.local = true if local_groups.size > 0
        end
      end
    end
    fattr(:projects) { [] }
    fattr(:group_configs) { [] }
    fattr(:groups) do
      group_configs.map { |x| x.loaded_group }
    end

    def project(name,&b)
      c = DSLWrapper.new(Single.new(:name => name))
      b[c]
      self.projects << c.obj
    end

    def group(name,&b)
      c = GroupWrapper.new(Group.new(:name => name))
      c.configs = self
      b[c]
      self.group_configs << c
    end

    def local_group
      local_config = group_configs.find { |x| x.local }
      local_config.andand.loaded_group
    end

    def group_for_dir(dir)
      dir = File.expand_path(dir)
      dir = dir.gsub("/Users/mharris717/Dropbox/CodeLink","/code")
      groups.find do |group|
        group.singles.any? do |proj|
          path = File.expand_path(proj.path)
          path = path.gsub("/Users/mharris717/Dropbox/CodeLink","/code")
          File.expand_path(path) == dir
        end
      end
    end

    class << self
      fattr(:instance) { new }
      fattr(:loaded) do
        instance.load!
        instance
      end
      def project(name,&b)
        instance.project(name,&b)
      end
      def group(name,&b)
        instance.group(name,&b)
      end

      def get_group(name)
        loaded.groups.find { |x| x.name == name }.tap { |x| raise "no group #{name}" unless x }
      end
    end
  end
end
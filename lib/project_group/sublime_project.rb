module ProjectGroup
  class SublimeProject
    include FromHash
    attr_accessor :group
    def as_json
      folders = group.singles.sort_by { |x| x.short_name }.map do |proj|
        {"path" => proj.path, 
         "name" => proj.short_name, 
         "folder_exclude_patterns" => folder_exclude_patterns(proj),
         "file_exclude_patterns" => file_exclude_patterns(proj)}
      end
      {"folders" => folders}
    end
    def to_json
      as_json.to_json
    end

    def folder_exclude_patterns(proj)
      res = []
      res += ["tmp","junk",".bundle","dist","node_modules","pkg","coverage","junk","bower_components"]
      res += ["__pycache__"]
      res += ["lib","bin","include"] if proj.type.to_s == 'python'
      res
    end

    def file_exclude_patterns(proj)
      res = [".rspec",".document","LICENSE.txt","*.gemspec","README.rdoc",".overapp","npm-debug.log"]
      res += [".editorconfig",".bowerrc",".gitkeep"]
      res += ["__init__.py"]
      res
    end

    fattr(:path) do
      File.expand_path("~/.project_group/sublime_projects/#{group.name}.sublime-project")
    end

    def write!
      File.create path, to_json
    end
  end

  class SymDir
    include FromHash
    attr_accessor :group

    fattr(:target) do
      "/users/mharris717/.project_group_syms/#{group.name}"
    end

    def create!
      FileUtils.mkdir_p target
      group.singles.each do |proj|
        ec "ln -s #{proj.path} #{target}/#{proj.short_name}"
      end
    end
  end

  register_plugin("open", level: :group) do |group|
    proj = SublimeProject.new(:group => group)
    proj.write!
    ec "subl --project #{proj.path}"
  end

end
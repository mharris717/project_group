module ProjectGroup
  class SublimeProject
    include FromHash
    attr_accessor :group
    def as_json
      folders = group.singles.map do |proj|
        {"path" => proj.path, "name" => proj.name, "folder_exclude_patterns" => ["tmp","junk",".bundle","dist"]}
      end
      {"folders" => folders}
    end
    def to_json
      as_json.to_json
    end

    fattr(:path) do
      File.expand_path("~/.project_group/sublime_projects/#{group.name}.sublime-project")
    end

    def write!
      File.create path, to_json
    end
  end
end

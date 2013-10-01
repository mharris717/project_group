module ProjectGroup
  class Single
    include FromHash

    attr_accessor :path
    fattr(:repo) do
      Repo.new(:path => path)
    end
    def uncommitted_files
      repo.changed_files.values.flatten.map { |x| OpenStruct.new(:relative_path => x) }
    end
    def needs_push?
      !repo.pushed?
    end
  end
end
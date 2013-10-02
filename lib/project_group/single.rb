module ProjectGroup
  class Single
    include FromHash

    attr_accessor :path, :name
    fattr(:name) do
      File.basename(path)
    end
    def repo
      Repo.new(:path => path)
    end
    def uncommitted_files
      repo.changed_files.values.flatten.map { |x| OpenStruct.new(:relative_path => x) }
    end
    def needs_push?
      !repo.pushed?
    end

    def status
      {:committed => !repo.changes?, :pushed => repo.pushed?}
    end
    def spec_output
      `cd #{path} && bundle exec rake spec`
    end
  end
end
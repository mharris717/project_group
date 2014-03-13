module ProjectGroup
  class Single
    include FromHash

    attr_accessor :path, :name, :type
    fattr(:short_name) { name }
    fattr(:name) do
      File.basename(path)
    end
    def eci(cmd,ops={})
      cmd = "cd #{path} && #{cmd}"
      ec cmd,ops
    end
    def relative_files  
      Dir["#{path}/**/*.*"].map do |full|
        res = full.gsub("#{path}/","")
        raise "bad #{res}" if res == full
        res
      end
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

    def to_s
      "#{name} (#{type}): #{path}"
    end
  end
end
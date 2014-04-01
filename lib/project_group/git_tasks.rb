module ProjectGroup
  class GitTasks
    include FromHash
    attr_accessor :proj
    def repo; proj.repo; end

    def gemspec!
      repo.cmd "gamble_exec rake gemspec"
      fix_gemspec!
    end

    def fix_gemspec!
      repo.git("checkout HEAD #{proj.short_name}.gemspec") if repo.only_gemspec_date_change?
    end

    def build_deps!
      repo.cmd "gamble_exec --bundlecmd install && gamble_exec rake gemspec"
      fix_gemspec!
    end

    def push!
      repo.git("push origin master:master") if !repo.pushed?
    end

    def commit_dep_files!
      if repo.changes? && repo.only_dep_changes?
        repo.commit_dep_files!
      end
    end

    def gt!
      ec "gittower -s #{proj.path}"
      puts "Enter to Continue"
      STDIN.gets
    end

    def all!
      gemspec!
      commit_dep_files!
      push!
    end


    def run!
      puts "Doing git for #{proj.short_name}"
      build_deps!
      all!

      if repo.changes?
        gt!
        all!
        raise "still changes" if repo.changes?
      end
    end
  end

  register_plugin("gitp", use_group: true) do |proj|
    GitTasks.new(proj: proj).run!
  end
end
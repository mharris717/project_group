module ProjectGroup
  class GitTasks
    include FromHash
    attr_accessor :proj, :changed
    def repo; proj.repo; end

    def gem?
      proj.type.to_s == 'gem'
    end

    def gemfile?
      gem? || proj.type.to_s == 'rails'
    end

    def gemspec!
      if gem?
        repo.cmd "bundle exec rake gemspec"
        fix_gemspec!
      end
    end

    def fix_gemspec!
      return unless gem?
      n = proj.short_name
      n = "baseball_server" if n == 'server'
      repo.git("checkout HEAD #{n}.gemspec") if repo.only_gemspec_date_change?
    end

    def build_deps!
      repo.cmd "bundle install" if gemfile?
      if gem?
        gemspec!
      end
    end

    def push!
      repo.git("push origin master:master") if !repo.pushed?
    end

    def commit_dep_files!
      return unless gemfile?
      if repo.changes? && repo.only_dep_changes?
        self.changed = true
        puts "committing dep"
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


    def run!(ops={})
      if ops[:only_if_changes]
        if !repo.changes? || repo.only_dep_changes?
          puts "Skipping #{proj.short_name}"
          return
        end
      end

      puts "Doing git for #{proj.short_name}"
      build_deps!
      all!

      if repo.changes?
        self.changed = true
        gt!
        all!
        raise "still changes" if repo.changes?
      end

      if changed
        if %w(mongoid_gem_config define_task mharris_spec).include?(proj.short_name)
          repo.cmd "bundle exec rake install"
        end
      end
    end
  end

  register_plugin("gitp", use_group: true) do |proj|
    GitTasks.new(proj: proj).run!
  end
  register_plugin("gitps", use_group: true) do |proj|
    GitTasks.new(proj: proj).run! only_if_changes: true
  end
end
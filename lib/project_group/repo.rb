module ProjectGroup
  class Repo
    include FromHash
    attr_accessor :path
    def name
      raise "name call"
    end
    def cmd(str)
      c = "cd #{path} && #{str}"
      #puts c
      res = ProjectGroup.ec(c)
      #puts res
      res
    end
    def git(*args)
      raise "no git repo for #{path}" unless FileTest.exist?("#{path}/.git")
      str = args.join(" ")
      cmd "git #{str}"
    end

    fattr(:repo) do
      raise "path doesn't exist #{path}" unless FileTest.exist?(path)
      raise "git path doesn't exist #{path}" unless FileTest.exist?("#{path}/.git")
      Grit::Repo.new(path)
    end

    def print!
      puts "Gem: #{name}".color(:white)
      if !current?
        changed_files.each do |type,files|
          files.each do |f|
            puts "#{type}: #{f}"
          end
        end
        puts "Needs Push #{local_ref} -> #{remote_ref}" unless pushed?
      else
        puts "No Changes"
      end
    end

    def use_file?(f)
      return false if %w(build tmp log pkg vendor junk doc coverage).any? { |x| x == f.split("/").first }
      return false if f =~ /public\/assets/
      return false if f.split(".").last == "log"
      return false if f =~ /testflight_launcher/
      return false if f =~ /(time|load)\.txt/
      return false if f =~ /dump\.rdb/
      return false if f =~ /profiles\//
      true
    end

    def shell_changes?
      res = ec "cd #{path} && git status"
      res = (res =~ /nothing to commit, working directory clean/i)
      !res
    end

    fattr(:changed_files) do
      res = {:modified => [], :added => [], :untracked => []}
      s = repo.status
      #puts s.changed.inspect

      s.changed.each do |path,file|
        res[:modified] << path if use_file?(path)
      end

      s.added.each do |path,file|
        res[:added] << path if use_file?(path)
      end

      s.untracked.each do |path,file|
        res[:untracked] << path if use_file?(path)
      end

      res
    end

    def changes?
      res = changed_files.values.any? { |x| x.size > 0 }
      res && shell_changes?
    end

    def only_dep_changes?
      return false unless changes?
      files = changed_files.values.flatten.uniq
      files.all? do |file|
        file =~ /(gemfile|gemspec)/i 
      end
    end 

    def commit_dep_files!
      gemspec = if Dir["#{path}/*.gemspec"].size > 0
        "*.gemspec"
      else
        ""
      end
      ec "cd #{path} && git add Gemfile Gemfile.lock #{gemspec} && git commit -m 'Dep Files'"
    end

    def ensure_dep_files!
      commit_dep_files! if changes? && only_dep_changes?
    end

    fattr(:remote_ref) do
      remote = repo.remotes.find { |x| x.name == "origin/master" }
      if remote
        remote.commit.to_s
      else
        nil
      end
    end
    fattr(:local_ref) do
      res = repo.commits("master",1).first
      if !res
        raise "no local ref for #{path} " + `cd #{path} && ls -al`
      end
      res.sha.to_s
    end
    def pushed?
      remote_ref == local_ref
    end

    def current?
      !changes? && pushed?
    end

    def needs_desc
      "Remote #{remote_ref} Local #{local_ref} Changes #{changed_files.inspect}"
    end

    def push_check!
      repo!; local_ref!
      return if pushed?
      print "Push? "
      resp = STDIN.gets.to_s.strip.downcase
      if resp == 'y'
        git "push origin master"
      end
    end

    def has_remote?
      git(:remote).present?
    end

    def only_gemspec_date_change?
      c = changed_files
      return false unless c[:added].empty? || c[:untracked].empty?
      return false unless c[:modified].size == 1 && c[:modified].first =~ /\.gemspec/

      lines = ec("cd #{path} && git diff", silent: true).split("\n")
      lines = lines.select { |line| line =~ /^[\+\-] / }
      return false unless lines.size == 2 && lines.select { |x| x[0..0] == '+' }.size == 1
      lines.all? { |line| line =~ /s\.date/ }
    end
  end
end
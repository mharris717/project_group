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
      return false if %w(build tmp log pkg vendor junk doc).any? { |x| x == f.split("/").first }
      return false if f =~ /public\/assets/
      return false if f.split(".").last == "log"
      return false if f =~ /testflight_launcher/
      true
    end

    fattr(:changed_files) do
      res = {:modified => [], :added => [], :untracked => []}
      s = repo.status

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
      changed_files.values.any? { |x| x.size > 0 }
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

    def push_check!
      repo!; local_ref!
      return if pushed?
      print "Push? "
      resp = STDIN.gets.to_s.strip.downcase
      if resp == 'y'
        git "push origin master"
      end
    end
  end
end
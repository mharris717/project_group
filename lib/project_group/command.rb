class File
  class << self
    def gsub!(file,*args)
      body = read(file)
      body = body.gsub(*args)
      File.create file, body
    end
  end
end

module ProjectGroup
  class Command
    include FromHash
    attr_accessor :cmd, :group_name, :project_name, :remaining_args, :use_group

    fattr(:configs) do
      Configs.loaded
    end

    fattr(:dir) do
      Dir.getwd
    end

    fattr(:group) do
      # explicit group name given: use entire group
      if group_name
        configs.groups.find { |x| x.name == group_name }

      # we have a local config file
      elsif configs.local_group
        configs.local_group

      # working dir is part of a group
      elsif configs.group_for_dir(dir)
        if use_group
          configs.group_for_dir(dir)
        else
          s = configs.single_for_dir(dir)
          OpenStruct.new(:singles => [s])
        end
      end.tap do |res| 
        if !res
          str = ["No Group found for #{dir}",configs.to_s].join("\n")
          raise str
        end
      end
    end

    def singles_for_project_name
      names = project_name.split(",")
      res = configs.all_singles.select { |x| names.include?(x.name) }
      g = configs.group_for_dir(dir)
      if g
        res += g.singles.select { |x| names.include?(x.short_name) }
      end
      res.uniq
    end

    def singles
      if project_name
        singles_for_project_name
      else
        group.ordered_singles
      end
    end

    def run!
      configs
      if Plugins.instance.has?(cmd)
        self.use_group = true if Plugins.instance.option(cmd,:use_group) || Plugins.instance.option(cmd,:level) == :group
        Plugins.instance.run(cmd, singles, :remaining_args => remaining_args, :group => group)
      else
        send(cmd)
      end
    end

    def cycle
      singles.each do |proj|
        puts "#{proj.path} #{proj.status.inspect} #{proj.spec_output}"
      end 
    end

    def info
      puts "Group #{group.name}"
      group.singles.each do |proj|
        puts "#{proj.name} #{proj.path}"
      end
    end

    def push
      singles.each do |proj|
        if !proj.repo.pushed?
          ec "cd #{proj.path} && git push origin master:master"
        end
      end
    end

    def config
      ec "subl ~/.project_group"
    end

    

    def bump_version
      singles.each do |proj|
        v = ec("cd #{proj.path} && bundle exec rake version").split(" ").last
        if v != '0.3.0'
          cmds = []
          cmds << lambda { git_full_single(proj) }
          cmds << "bundle exec rake version:write MAJOR=0 MINOR=3 PATCH=0"
          cmds << "bundle exec rake gemspec"
          cmds << "git add *.gemspec"
          cmds << lambda do
            if proj.repo.changes?
              ec "cd #{proj.path} && git commit --amend -m 'Version bump to 0.3.0'"
            end
          end
          cmds << "git push origin master:master"
          cmds << "bundle exec rake git:release"

          cmds.each do |cmd|
            if cmd.kind_of?(String)
              ec "cd #{proj.path} && #{cmd}"
            else
              cmd.call
            end
          end
        else
          git_full_single(proj)
        end
      end
    end

    def update_private_gem(path)
      file = "#{path}/Gemfile"
      body = File.read(file)

      fresh = '#### SPECIAL GEMFILE BLOCK START
def private_gem(name)
  gem name, git: "https://#{ENV[\'GITHUB_TOKEN\']}:x-oauth-basic@github.com/mharris717/#{name}.git", branch: :master
end
#### SPECIAL GEMFILE BLOCK END'

      fresh = '#### SPECIAL GEMFILE BLOCK START
if FileTest.exist?("/code/orig/private_gem/private_gem.rb")
  load "/code/orig/private_gem/private_gem.rb"
else
  def private_gem(name)
    gem name, git: "https://#{ENV[\'GITHUB_TOKEN\']}:x-oauth-basic@github.com/mharris717/#{name}.git", branch: :master
  end
end
#### SPECIAL GEMFILE BLOCK END'

      body = body.gsub(/#### SPECIAL GEMFILE BLOCK START.*#### SPECIAL GEMFILE BLOCK END/m,fresh)
      File.create file, body
    end

    def pgem
      singles.each do |proj|
        update_private_gem(proj.path)
      end
    end

    def gem_stuff
      singles.select { |proj| proj.repo.changes? || !proj.repo.pushed? }.each do |proj|
        if proj.repo.changes?
          ec "cd #{proj.path} && git add Gemfile Gemfile.lock *.gemspec && git commit -m 'Gem Deps and gemspec'"
        end
        if !proj.repo.pushed?
          ec "cd #{proj.path} && git push origin master:master"
        end
      end
    end

    def gemspec
      singles.each do |proj|
        puts `cd #{proj.base_path} && rake gemspec`
      end
    end

    def release
      gemspec = lambda do |proj|
        puts `cd #{proj.base_path} && rake gemspec`
      end
      one = lambda do
        singles.each { |x| gemspec[x] }
        singles.select { |proj| proj.repo.changes? || !proj.repo.pushed? }.each do |proj|
          gemspec[proj]
          ec "gittower #{proj.path}"
          puts "Enter to Continue"
          STDIN.gets
          gemspec[proj]
        end
      end

      while one[].size > 0
        a = 4
      end
    end

    def symdir
      SymDir.new(group: group).create!
    end

    def list
      configs.groups.each do |g|
        puts g.name
      end
    end

    def reach
      each_cmd = remaining_args.join(" ")
      singles.each do |proj|
        ec "cd #{proj.path} && #{each_cmd}"
      end
    end


    def parse!(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options] <file>"

        opts.on("-n", "--name name", "Group Name") do |v|
          self.group_name = v
        end

        opts.on("-p", "--projectname name", "Project Name") do |v|
          self.project_name = v
        end

        opts.on("-g", "--group", "Use Group") do |v|
          self.use_group = v
        end
      end.parse!(args)
      self.cmd = args.first
      self.remaining_args = args[1..-1]
    end
  end
end
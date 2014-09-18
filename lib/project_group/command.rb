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
  class MockGroup
    include FromHash
    attr_accessor :singles_inner
    %w(singles_inner_safe ordered_singles).each do |m|
      define_method(m) { singles_inner }
    end
    def singles=(x)
      self.singles_inner = x
    end
    def singles(ops={})
      singles_inner
    end
  end

  module DetermineProjects
    attr_accessor :group_method_used
    def on_fly_group
      path = File.expand_path(".")
      name = File.basename(path)
      single = ProjectGroup::Single.new(path: path, name: name, type: :unknown)
      ProjectGroup::Group.new(name: name, singles_inner: [single])
    end
    fattr(:group) do
      # explicit group name given: use entire group
      if group_name
        self.group_method_used = "group_name"
        configs.groups.find { |x| x.name == group_name }

      # we have a local config file
      elsif configs.local_group
        self.group_method_used = "configs.local_group"
        configs.local_group

      # working dir is part of a group
      elsif configs.group_for_dir(dir)
        
        if use_group
          self.group_method_used = "group_for_dir use_group"
          configs.group_for_dir(dir)
        else
          self.group_method_used = "group_for_dir single_for_dir"
          s = configs.single_for_dir(dir)
          raise "no single" unless s
          MockGroup.new(singles: [s])
        end
      elsif on_fly
        self.group_method_used = "on_fly"
        on_fly_group
      end.tap do |res| 
        #puts "Method Used: #{group_method_used}"
        if !res
          str = ["No Group found for #{dir}",configs.to_s].join("\n")
          raise str
        end
      end
    end

    def singles_for_project_name
      if project_name.to_s.strip == '.'
        return [configs.single_for_dir(dir, safe: true)]
      end

      # project_name can be comma delimited list of multiple, turn into a list
      names = project_name.split(",")

      # looking in all groups, get matching singles
      res = configs.all_singles.select { |x| names.include?(x.name) }

      # if current dir has a group, also look more closely at singles in that group
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
        group.singles order: order_singles
      end.tap { |x| raise "no singles #{x.class}" unless x && x.size > 0 }
    end
  end

  class Command
    include FromHash
    include DetermineProjects

    attr_accessor :cmd, :group_name, :project_name, :remaining_args, :use_group, :on_fly, :order_singles

    fattr(:configs) do
      Configs.loaded
    end

    fattr(:dir) do
      Dir.getwd
    end

    def run!
      configs
      if Plugins.instance.has?(cmd)
        Plugins.instance.full_run(self, :remaining_args => remaining_args)
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
        proj.eci "bundle exec rake gemspec"
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

        opts.on("-f", "--onfly","On Fly") do |v|
          self.on_fly = v
        end
      end.parse!(args)
      self.cmd = args.first
      self.remaining_args = args[1..-1]
    end
  end
end
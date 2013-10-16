module ProjectGroup
  class SinglesFinder
    include FromHash
    attr_accessor :group_name, :project_name
  end
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
      if group_name
        configs.groups.find { |x| x.name == group_name }
      elsif configs.local_group
        configs.local_group
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
      res = configs.all_singles.select { |x| x.name == project_name }
      g = configs.group_for_dir(dir)
      if g
        res += g.singles.select { |x| x.short_name == project_name }
      end
      res.uniq
    end

    def singles
      if project_name
        singles_for_project_name
      else
        group.singles
      end
    end

    def run!
      configs
      if Plugins.instance.has?(cmd)
        Plugins.instance.run(cmd, singles, :remaining_args => remaining_args)
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

    def open
      proj = SublimeProject.new(:group => group)
      proj.write!
      ec "subl --project #{proj.path}"
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

    def git
      one = lambda do
        singles.select { |proj| proj.repo.changes? || !proj.repo.pushed? }.each do |proj|
          ec "gittower #{proj.path}"
          puts "Enter to Continue"
          STDIN.gets
        end
      end

      while one[].size > 0
        a = 4
      end
    end

    def release
      gemspec = lambda do |proj|
        `cd #{proj.base_path} && rake gemspec`
      end
      one = lambda do
        singles.each { |x| gemspec[x] }
        singles.select { |proj| proj.repo.changes? || !proj.repo.pushed? }.each do |proj|
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

    def list
      configs.groups.each do |g|
        puts g.name
      end
    end

    def parse!(args)
      self.cmd = args.first
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
      self.remaining_args = args[1..-1]
    end
  end
end
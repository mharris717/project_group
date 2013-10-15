module ProjectGroup
  class Command
    include FromHash
    attr_accessor :cmd, :group_name, :project_name

    fattr(:configs) do
      Configs.loaded
    end

    fattr(:dir) do
      Dir.getwd
    end

    fattr(:group) do
      if group_name
        configs.groups.find { |x| x.name == group_name }
      elsif Configs.loaded.local_group
        configs.local_group
      elsif Configs.loaded.group_for_dir(dir)
        configs.group_for_dir(dir)
      end.tap { |x| raise "no group #{group_name}" unless x }
    end

    def singles
      if project_name
        res = configs.all_singles.select { |x| x.name == project_name }
        groupx = configs.group_for_dir(dir)
        if groupx
          res += groupx.singles.select { |x| x.short_name == project_name }
        end
        res.uniq
      else
        group.singles
      end
    end

    def run!
      send(cmd)
    end

    def cycle
      group.singles.each do |proj|
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
      group.singles.each do |proj|
        if !proj.repo.pushed?
          ec "cd #{proj.path} && git push origin master:master"
        end
      end
    end

    def config
      ec "subl ~/.project_group"
    end

    def git
      group.singles.each do |proj|
        if proj.repo.changes?
          ec "gittower #{proj.path}"
          puts "Enter to Continue"
          STDIN.gets
        end
      end
    end

    def list
      Configs.loaded.groups.each do |g|
        puts g.name
      end
    end

    def parse!(args)
      self.cmd = args.first
      OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on("-n", "--name name", "Group Name") do |v|
          self.group_name = v
        end

        opts.on("-p", "--projectname name", "Project Name") do |v|
          self.project_name = v
        end
      end.parse!(args)
    end
  end
end
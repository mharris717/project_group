module ProjectGroup
  class Command
    include FromHash
    attr_accessor :cmd, :group_name

    fattr(:groupx) do
      res = Group.new
      res << "/code/orig/project_group"
      res
    end

    fattr(:group) do
      if group_name
        Configs.loaded.groups.find { |x| x.name == group_name }
      else
        Configs.loaded.local_group
      end.tap { |x| raise "no group #{group_name}" unless x }
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

    def git
      group.singles.each do |proj|
        if proj.repo.changes?
          ec "gittower #{proj.path}"
          puts "Enter to Continue"
          STDIN.gets
        end
      end
    end

    def parse!(args)
      self.cmd = args.first
      OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on("-n", "--name name", "Group Name") do |v|
          self.group_name = v
        end
      end.parse!(args)
    end
  end
end
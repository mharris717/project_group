module ProjectGroup
  class Command
    include FromHash
    attr_accessor :cmd

    fattr(:group) do
      res = Group.new
      res << "/code/orig/project_group"
      res
    end

    def run!
      if cmd == 'cycle'
        cycle
      else
        raise cmd.to_s
      end
    end

    def cycle
      group.singles.each do |proj|
        if proj.repo.current?
          puts "current #{proj.path}"
        else
          puts "not current #{proj.path}"
        end
      end 
    end
  end
end
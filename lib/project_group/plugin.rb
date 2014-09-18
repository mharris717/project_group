module ProjectGroup
  class Plugin
    include FromHash
    attr_accessor :name, :block, :options

    def call(proj,ops)
      block.call(proj,ops)
    end

    def group_level?
      (options || {})[:level] == :group
    end
  end

  class Plugins
    class << self
      fattr(:instance) { new }
    end

    fattr(:list) { [] }
    def add(name,b,ops={})
      self.list << Plugin.new(:name => name, :block => b, :options => ops)
    end

    def get(cmd)
      list.find { |x| x.name.to_s.downcase == cmd.to_s.downcase }
    end
    def has?(cmd)
      !!get(cmd)
    end
    def run(cmd,singles,ops={})
      plugin = get(cmd)
      if plugin.group_level?
        plugin.call ops[:group],ops
      else
        raise "no singles #{singles.class}" unless singles && singles.size > 0
        singles.each do |s|
          plugin.call(s,ops)
        end
      end
    end
    def full_run(command,ops={})
      command.use_group = true if option(command.cmd,:use_group) || (option(command.cmd,:level) == :group)
      command.order_singles = true if option(command.cmd,:order_singles)
      ops[:group] = command.group
      run(command.cmd,command.singles,ops)
    end
    def option(cmd,op)
      res = get(cmd)
      if res
        res.options[op]
      else
        nil
      end
    end
  end
end
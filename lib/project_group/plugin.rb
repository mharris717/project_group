module ProjectGroup
  class Plugin
    include FromHash
    attr_accessor :name, :block, :options

    def call(proj,ops)
      block.call(proj,ops)
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
      singles.each do |s|
        get(cmd).call(s,ops)
      end
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
require 'mharris_ext'
require 'grit'
require 'ostruct'
require 'json'
require 'optparse'
require 'andand'

module ProjectGroup
  class << self
    def ec(cmd)
      `#{cmd}`
    end
  end
end

module ProjectGroup
  class << self
    def load!
      %w(single repo group command config sublime_project run_tests plugin).each do |f|
        load File.dirname(__FILE__) + "/project_group/#{f}.rb"
      end
    end

    def register_plugin(name,ops={},&b)
      obj = if ops.kind_of?(Hash)
        ops[:obj] || b
      elsif !ops
        raise 'bad'
      else
        ops
      end

      ops.delete(:obj)

      Plugins.instance.add(name,obj,ops)
    end
  end
end

ProjectGroup.load!

ProjectGroup.register_plugin("reach2", use_group: true) do |proj,ops|
  cmd = ops[:remaining_args].join(" ")
  proj.eci cmd
end
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

#require 'remote_cache'
#load "/code/orig/mongoid_gem_config/lib/mongoid_gem_config.rb"
#load "/code/orig/remote_cache/lib/remote_cache.rb"
ProjectGroup.register_plugin("reach2", use_group: true) do |proj,ops|
  cmd = ops[:remaining_args].join(" ")
  #RC.cmd "cd #{proj.path} && #{cmd}"
  proj.eci cmd
end

class Fun
  def abcxyz
    42
  end
  fattr(:xyzabc) do
    42
  end
end

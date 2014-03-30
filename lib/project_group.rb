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
      %w(plugin single repo group command config sublime_project run_tests git_tasks).each do |f|
        load File.dirname(__FILE__) + "/project_group/#{f}.rb"
      end

      %w(string_ext).each do |f|
        load File.dirname(__FILE__) + "/project_group/ext/#{f}.rb"
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

def do_until_success(&b)
  loop do
    begin
      res = b[]
      return res
    rescue => exp
      puts exp.message
      puts "Enter to Continue:"
      STDIN.gets
    end
  end
end

ProjectGroup.load!

ProjectGroup.register_plugin("reach", use_group: true) do |proj,ops|
  cmd = ops[:remaining_args].join(" ")
  #RC.cmd "cd #{proj.path} && #{cmd}"
  do_until_success do
    proj.eci cmd
  end
end

ProjectGroup.register_plugin("gt", use_group: true) do |proj,ops|
  if proj.repo.changes?
    proj.eci "gittower -s"
    puts "Enter to Continue:"
    STDIN.gets
  end
end

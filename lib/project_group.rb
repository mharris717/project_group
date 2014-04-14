require 'mharris_ext'
require 'grit'
require 'ostruct'
require 'json'
require 'optparse'
require 'andand'

module ProjectGroup
  class << self
    def ec(cmd)
      MharrisExt.ec cmd, silent: true
    end
  end
end

module ProjectGroup
  class << self
    def load!
      %w(plugin single repo group command config sublime_project run_tests git_tasks reach).each do |f|
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

def do_until_success(message=nil,&b)
  loop do
    begin
      res = b[]
      return res
    rescue => exp
      puts exp.message
      puts "#{message} Enter to Continue:"
      STDIN.gets
    end
  end
end

ProjectGroup.load!

ProjectGroup.register_plugin("reach", use_group: true) do |proj,ops|
  cmd = ops[:remaining_args].join(" ")
  #RC.cmd "cd #{proj.path} && #{cmd}"
  do_until_success(proj.short_name) do
    proj.eci cmd
  end
end

ProjectGroup.register_plugin("gt", use_group: true) do |proj,ops|
  if proj.repo.changes? && !proj.repo.only_dep_changes?
    proj.eci "gittower -s"
    puts "Enter to Continue:"
    STDIN.gets
  end
  proj.eci "git push origin master:master"
end

ProjectGroup.register_plugin("tasks", use_group: true) do |proj,ops|
  #names = ops[:group].singles.map { |x| x.short_name } + ['define_task']
  #local = names.join(",")
  #cmd = "/code/orig/local_exec/bin/local_exec --addl mongoid_gem_config,define_task --local #{local} list_rake_tasks"
  cmd = "bundle exec list_rake_tasks"
  proj.eci(cmd, silent: true).split("\n").each do |task|
    puts "TASK #{proj.short_name}:#{task}"
  end
end

ProjectGroup.register_plugin("fury", use_group: true) do |proj,ops|
  proj.eci "rm -r pkg" if FileTest.exist?("#{proj.path}/pkg")
  proj.eci "bundle exec rake build"
  file = Dir["#{proj.path}/pkg/*.gem"].first
  raise "bad" unless file.present?
  proj.eci "fury push #{file}"
end
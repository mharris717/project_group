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

%w(single repo group command config sublime_project).each do |f|
  load File.dirname(__FILE__) + "/project_group/#{f}.rb"
end
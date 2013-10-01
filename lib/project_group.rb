require 'mharris_ext'
require 'grit'

module ProjectGroup
  class << self
    def ec(cmd)
      `#{cmd}`
    end
  end
end
%w(single repo group command).each do |f|
  load File.dirname(__FILE__) + "/project_group/#{f}.rb"
end
require 'mharris_ext'
load "lib/project_group.rb"

class Deps
  include FromHash
  # A => [B]
  # B depends on A
  fattr(:deps) do
    Hash.new { |h,k| h[k] = [] }
  end

  # child depends on parent
  def dep(parent,child=nil)
    deps[parent]

    if child
      deps[child]
      deps[parent] << child
    end
  end

  # B => [A]
  # B depends on A
  fattr(:reverse_deps) do
    res = Hash.new { |h,k| h[k] = [] }
    deps.each do |parent,children|
      children.each do |child|
        res[child] << parent
      end
    end
    res
  end

  def nodes
    (deps.keys + deps.values).flatten.uniq
  end

  fattr(:processed) { [] }
  def unprocessed
    nodes - processed
  end

  def process_one!
    processed_round = []

    unprocessed.each do |node|
      parents = reverse_deps[node]
      if parents.all? { |x| processed.include?(x) }
        processed_round << node
      end
    end

    raise "bad" if processed_round.empty?

    self.processed += processed_round
  end

  def process!
    while unprocessed.size > 0
      process_one!
    end
  end

  def full_deps_for(child)
    res = {}
    reverse_deps[child].each do |parent|
      res[parent] = true
      full_deps_for(parent).each { |x| res[x] = true }
    end
    res.keys
  end

  fattr(:full_deps) do
    res = {}
    nodes.each do |node|
      res[node] = full_deps_for(node)
    end
    res
  end
end

class MyGem
  include FromHash
  attr_accessor :name
  fattr(:path) { "/code/orig/#{name}" }

  fattr(:gem_deps) do
    line = 'puts Bundler.environment.specs.map { |s| "#{s.name} #{s.version}" }.sort.join("\n")'
    cmd = "cd #{path} && bundle exec ruby -e '#{line}'"
    res = ec(cmd, silent: true)
    res.split("\n").map { |x| x.strip }.select { |x| x.present? }.map { |x| x.split(" ").first }
  end

  def local_deps(group)
    gem_deps.select do |d|
      group.singles.any? { |single| single.name.to_s.gsub(/^#{group.name}-/,"") == d }
    end
  end
end

class GroupDeps
  include FromHash
  attr_accessor :group_name
  fattr(:group) do
    ProjectGroup::Configs.loaded.groups.find { |x| x.name == group_name }
  end

  fattr(:gems) do
    group.singles.map do |s|
      MyGem.new(name: s.short_name, path: s.path)
    end
  end

  fattr(:deps_obj) do
    res = Deps.new
    gems.each do |g|
      res.dep g.name
      g.local_deps(group).each do |parent|
        res.dep parent,g.name
      end
    end
    res.process!
    res
  end
end

def stuff
  s = GroupDeps.new(group_name: "gambling")
  puts s.deps_obj.processed.inspect

  s.deps_obj.full_deps.each do |k,vs|
    puts "#{k}: #{vs.inspect}"
  end

  File.create "vol/deps.inspect",s.deps_obj.deps.inspect
  File.create "vol/full_deps.inspect",s.deps_obj.full_deps.inspect
end

stuff

s = GroupDeps.new(group_name: "gambling")
deps = eval(File.read("vol/deps.inspect"))
s.deps_obj = Deps.new(deps: deps)
s.deps_obj.full_deps.each do |k,vs|
  puts "#{k}: #{vs.inspect}"
end

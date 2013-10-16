module ProjectGroup
  class Group
    include FromHash
    attr_accessor :name
    fattr(:singles) { [] }
    def <<(path)
      self.singles << Single.new(:path => path)
    end
    def uncommitted_files
      singles.map { |x| x.uncommitted_files }.flatten
    end
    def needs_push?
      singles.any? { |x| x.needs_push? }
    end

    def to_s
      res = []
      res << "Group: #{name}"
      res << "Singles (#{singles.size}): "
      singles.each { |x| res << x.to_s }
      res.join("\n")
    end
  end
end
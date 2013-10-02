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
  end
end
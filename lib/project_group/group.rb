module ProjectGroup
  class Group
    include FromHash
    fattr(:singles) { [] }
    def <<(path)
      self.singles << Single.new(:path => path)
    end
    def uncommitted_files
      singles.map { |x| x.uncommitted_files }.flatten
    end
  end
end
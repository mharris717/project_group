module ProjectGroup
  class Group
    include FromHash
    attr_accessor :name, :single_order
    fattr(:singles_inner) { [] }
    def <<(path)
      self.singles_inner << Single.new(:path => path)
    end
    fattr(:real_single_order) do
      if FileTest.exist?("/code/orig/dep_local/bin/group_dep_order")
        ec("/code/orig/dep_local/bin/group_dep_order #{name}").split("\n")
      else
        []
      end
    end
    def sort_index(single)
      (real_single_order || []).each_with_index do |o,i|
        return i if single.name.to_s == o.to_s || single.short_name.to_s == o.to_s
      end
      9999
    end
    def singles
      singles_inner
    end
    def ordered_singles
      singles_inner.sort_by { |x| sort_index(x) }
    end
    def singles=(x)
      self.singles_inner = x
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
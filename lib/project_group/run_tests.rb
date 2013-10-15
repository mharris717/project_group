module ProjectGroup
  class RunTests

    class Single
      include FromHash
      attr_accessor :path, :command

      def run!
        ProjectGroup.ec(full_command)
      end

      def full_command
        "cd #{path} && #{command}"
      end
    end

    fattr(:singles) { [] }

    def add(ops)
      self.singles << Single.new(ops)
    end

    def run!
      singles.each { |x| x.run! }
    end
  end
end

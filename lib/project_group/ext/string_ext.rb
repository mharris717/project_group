class String
  def to_fixed_path
    res = File.expand_path(self)
    res = res.gsub("/Users/mharris717/Dropbox/CodeLink","/code")
    res = res.gsub("/Users/mharris717/code","/code")
    res
  end

  def same_path?(dir)
    to_fixed_path == dir.to_fixed_path
  end
end
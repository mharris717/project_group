class MakeInitial
  def tmp_dir
    File.expand_path(File.dirname(__FILE__) + "/../../tmp")
  end
  def projects_dir
    "#{tmp_dir}/projects"
  end
  def with_projects(&b)
    ec "rm -rf #{tmp_dir}" if FileTest.exists?(tmp_dir)
    ec "mkdir -p #{projects_dir}"
    Dir.chdir(projects_dir,&b)
  end
  def ec(cmd)
    res = `#{cmd}`
    #puts res
    res
  end
  def git(cmd)
    ec "git #{cmd}"
  end

  def project(name,&b)
    ec "mkdir #{name}"
    Dir.chdir(name) do
      ec "git init"
      git "remote add origin file:///abc/#{rand(10000000000000)}"
      yield
      #git "add ."
      #git "commit -m abc"
    end
  end

  def create(file,body="abc")
    File.create file,body
    git "add #{file}"
    git "commit -m #{file}"
  end

  def innerx
    project "foo" do
      create "a.txt"
    end

    project "bar" do
      create "a.txt"
      File.create "b.txt","zzz"
    end
  end

  def make(&b)
    with_projects do
      instance_eval(&b)
    end
  end

  class << self
    def make(&b)
      res = new
      res.make(&b)
    end
  end
end

def make_initial_old
  dir = File.expand_path(File.dirname(__FILE__) + "/../tmp")
  

  Dir.chdir(dir) do
    `rm -rf projects` if FileTest.exists?("projects")
    `mkdir projects`
    Dir.chdir("projects") do
      `mkdir foo`
      Dir.chdir('foo') do
        `git init`
        File.create "a.txt","abc"
        `git add a.txt`
        `git commit -m a.txt`
      end
      `mkdir bar`
      Dir.chdir('bar') do
        `git init`
        File.create "a.txt","abc"
        `git add a.txt`
        `git commit -m a.txt`
        `echo z > b.txt`
      end
    end
  end
end
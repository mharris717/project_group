class MakeInitial
  def tmp_dir
    File.expand_path(File.dirname(__FILE__) + "/../../tmp")
  end
  def projects_dir
    "#{tmp_dir}/projects"
  end
  def origin_dir
    "#{tmp_dir}/origin"
  end
  def with_projects(&b)
    ec "rm -rf #{tmp_dir}" if FileTest.exists?(tmp_dir)
    ec "mkdir -p #{projects_dir}"
    ec "mkdir #{origin_dir}"
    ec "mkdir #{tmp_dir}/configs"
    ec "mkdir #{tmp_dir}/tmp1"
    Dir.chdir(projects_dir,&b)
  end
  def ec(cmd)
    #puts cmd
    res = `#{cmd} 2>&1`
    #puts res
    res
  end
  def git(cmd)
    ec "git #{cmd}"
  end

  def project(name,&b)
    Dir.chdir(origin_dir) do
      ec "mkdir #{name}.git"
      Dir.chdir("#{name}.git") do
        git "init --bare"
      end
    end
    ec "mkdir #{name}"
    Dir.chdir(name) do
      ec "git init"
      ec "git config user.email johnsmith@fake.com"
      ec "git config user.name \"John Smith\""
      git "remote add origin file://#{tmp_dir}/origin/#{name}.git"
      yield
    end
  end

  def push
    git "push origin master"
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
      instance_eval(&b) if b
    end
  end

  def run(&b)
    Dir.chdir(projects_dir) do
      instance_eval(&b)
    end
  end

  class << self
    def make(&b)
      res = new
      res.make(&b)
    end
    def run(&b)
      res = new
      res.run(&b)
    end
    def tmp_dir
      new.tmp_dir
    end
  end
end

shared_context "project" do
  class << self
    fattr(:project_blocks) { {} }
    def project(name=nil,&b)
      name ||= rand(100000000000).to_s
      self.project_blocks[name] = b
    end

    def setup_projects
      MakeInitial.make
      project_blocks.each do |name,b|
        MakeInitial.run do
          project(name) do
            instance_eval(&b)
          end
        end
      end
      sleep(0.1)
    end
  end

  let(:names) { self.class.project_blocks.keys }
  let(:name) { names.first }

  before(:all) do
    self.class.setup_projects
  end

  def make_project(name)
    dir = File.expand_path(File.dirname(__FILE__) + "/../../tmp/projects/#{name}")
    ProjectGroup::Single.new(:path => dir)
  end

  let(:proj) do
    make_project(name)
  end
  let(:singles) do
    names.map { |x| make_project(x) }
  end

  let(:group) do
    ProjectGroup::Group.new(:singles => singles)
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
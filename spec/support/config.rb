shared_context "config" do
  let(:configs) do
    ProjectGroup::Configs.instance
  end
  let(:local_config_body) { "" }
  let(:config_body) { "" }
  def setup_configs
    MakeInitial.make
    File.create("#{MakeInitial.tmp_dir}/configs/ezq.rb", config_body)
    File.create("#{MakeInitial.tmp_dir}/tmp1/.project_group.rb", local_config_body) 

    Dir.chdir("#{MakeInitial.tmp_dir}/tmp1") do
      c = ProjectGroup::Configs.instance!
      c.dir = "#{MakeInitial.tmp_dir}/configs"
      c.load!
      ProjectGroup::Configs.loaded = c
    end
  end
  before do
    setup_configs
  end

  let(:group_config) do
    configs.group_configs.first
  end
  let(:group) do
    configs.groups.first
  end
  let(:project) do
    configs.projects.first
  end
end
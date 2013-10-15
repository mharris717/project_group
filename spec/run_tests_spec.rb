require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Run Tests" do
  let(:tests) do
    res = ProjectGroup::RunTests.new
    res.add :path => "/tmp/foo", :command => "rake spec"
    res
  end

  it 'mock smoke' do
    a = []
    #expect(a).to receive(:push)
    a.should_receive(:push).with(7) { "fun" }
    res = a.push 7
    res.should == "fun"
  end

  it 'run' do
    ProjectGroup.should_receive(:ec).with("cd /tmp/foo && rake spec") { "foo" }
    tests.run!
  end
end
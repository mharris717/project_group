# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_port => 5710 do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
  watch(%r{^spec/support/.+\.rb$})
end

def test_once
  pid = fork do
    exec "bundle exec rake"
  end

  Process.wait pid
end

if true
  guard 'rspec', :cli => "--drb --drb-port 5710" do
    watch(%r{^spec/.+_spec\.rb$}) 
    watch(%r{^lib/(.+)\.rb$})   { "spec" } # { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^lib/(.+)\.treetop$})   { "spec" }
    watch(%r{^lib/(.+)\.csv$})   { "spec" }
    #watch(%r{^spec/support/(.+)\.rb$})   { "spec" }
    watch('spec/spec_helper.rb')  { "spec" }
  end
else
  guard :shell do
    watch /.*/ do |m|
      test_once
    end
  end
end



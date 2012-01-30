require 'bundler/setup'
require 'restclient'
require 'tempfile'
require 'xcode_build'
require 'xcode_build/tasks/build_task'
require 'xcode_build/formatters/progress_formatter'

namespace :authserver do
  desc "Starts the auth server on port 9292"
  task :start do
    system "bundle exec thin -p9292 -P Scripts/auth_server.pid -R Scripts/auth_server.ru -d start"
  end

  desc "Starts the auth server"
  task :stop do
    system "bundle exec thin -P Scripts/auth_server.pid -f stop"
  end

  desc "Resets the available users on the auth server"
  task :reset do
    if RestClient.post("http://admin:letmein@localhost:9292/reset", "") == "OK"
      puts "Users reset."
    end
  end

  desc "Restarts the auth server (and therefore resets it)"
  task :restart => [:stop, :start]
end

task :docs do
  system("appledoc --no-search-undocumented-doc --keep-intermediate-files --verbose 1 --output Documentation/generated --project-name libPusher Library/PT*")  
end

XcodeBuild::Tasks::BuildTask.new(:debug) do |t|
  t.workspace = "libPusher.xcworkspace"
  t.scheme = "libPusher"
  t.configuration = "Debug"
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
end

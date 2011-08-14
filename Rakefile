task :start_auth_server do
  system "bundle exec thin -p9292 -P Scripts/auth_server.pid -R Scripts/auth_server.ru -d start"
end

task :stop_auth_server do
  system "bundle exec thin -P Scripts/auth_server.pid -f stop"
end

task :restart_auth_server => [:stop_auth_server, :start_auth_server]

task :docs do
  system("appledoc --no-search-undocumented-doc --keep-intermediate-files --verbose 1 --output Documentation/generated --project-name libPusher Library/PT*")  
end

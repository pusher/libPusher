platform :ios, :deployment_target => '4.0'

dependency 'Reachability'
dependency 'SocketRocket', git: 'git://github.com/square/SocketRocket.git', :download_only => true

post_install do |installer|
  # we don't want to link static lib to the icucore dylib or it will fail to build
  default_target_installer = installer.target_installers.find { |i| i.target_definition.name == :default }
  config_file_path = File.join("Pods", default_target_installer.xcconfig_filename)
  
  File.open("config.tmp", "w") do |io|
    io << File.read(config_file_path).gsub(/-licucore/, '')
  end
  
  FileUtils.mv("config.tmp", config_file_path)
end

target :specs, :exclusive => true do
  dependency 'Kiwi', git: "git://github.com/allending/Kiwi.git", :download_only => true
end

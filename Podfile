platform :ios

dependency do |s|
  s.name     = 'JSONKit'
  s.version  = '1.5b'
  s.source   = { :git => 'https://github.com/johnezang/JSONKit.git', :commit => '0aff3deb5e' }
  s.source_files = 'JSONKit.*'
end

dependency 'SocketRocket', '0.1'

post_install do |installer|
  # we don't want to link static lib to the icucore dylib or it will fail to build
  default_target_installer = installer.target_installers.find { |i| i.definition.name == :default }
  config_file_path = File.join("Pods", default_target_installer.xcconfig_filename)
  
  File.open("config.tmp", "w") do |io|
    io << File.read(config_file_path).gsub(/-licucore/, '')
  end
  
  FileUtils.mv("config.tmp", config_file_path)
end

target :specs, :exclusive => true do
  dependency 'Kiwi', git: "git://github.com/allending/Kiwi.git"
end

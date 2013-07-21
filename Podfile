platform :ios, :deployment_target => '4.0'

pod 'Reachability'
pod 'SocketRocket', :head

post_install do |installer|
  # we don't want to link static lib to the icucore dylib or it will fail to build
  config_file_path = File.join("Pods", "Pods.xcconfig")
  
  File.open("config.tmp", "w") do |io|
    io << File.read(config_file_path).gsub(/-licucore/, '')
  end
  
  FileUtils.mv("config.tmp", config_file_path)
end

target :specs, :exclusive => true do
  link_with ['Functional Specs', 'UnitTests']
  
  pod 'Kiwi'
  pod 'OHHTTPStubs'
end

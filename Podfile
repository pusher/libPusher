# This podfile is intended for development on libPusher.
#
# If you are working on libPusher, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.
#
platform :ios, :deployment_target => '5.0'

inhibit_all_warnings!

pod 'Reachability', '3.1.1'
pod 'SocketRocket', :head # FIXME: we need a tagged dependency
pod 'ReactiveCocoa', '2.1.7'

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

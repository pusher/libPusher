# This podfile is intended for development on libPusher.
#
# If you are working on libPusher, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.
#
platform :ios, :deployment_target => '6.0'

inhibit_all_warnings!

pod 'Reachability', '~> 3.1'
pod 'SocketRocket', '~> 0.4.1'
pod 'ReactiveCocoa', '~> 2.1'

post_install do |installer|
  # we don't want to link static lib to the icucore dylib or it will fail to build
  builds = ["debug", "release"]
  
  builds.each do |build|
      config_file_path = File.join("Pods", "Target Support Files", "Pods", "Pods.#{build}.xcconfig")
      
      File.open("#{build}_config.tmp", "w") do |io|
          io << File.read(config_file_path).gsub(/-licucore/, '')
      end
      
      FileUtils.mv("#{build}_config.tmp", config_file_path)
  end
end

target :specs, :exclusive => true do
  link_with ['Functional Specs', 'UnitTests']
  
  pod 'Kiwi', '~> 2.3'
  pod 'OHHTTPStubs', '~> 3.0'
end

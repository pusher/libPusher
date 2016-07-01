# This podfile is intended for development on libPusher.
#
# If you are working on libPusher, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.
#
platform :ios, deployment_target: '6.0'

inhibit_all_warnings!

def import_pods
  pod 'Reachability', '~> 3.1'
  pod 'SocketRocket', '~> 0.5.0'
  pod 'ReactiveCocoa', '~> 2.1'
end

def import_test_pods
  pod 'Kiwi', '~> 2.4'
  pod 'OHHTTPStubs', '~> 5.0'
end


target 'libPusher' do
  import_pods
end

target 'libPusher_ReactiveExtensions.a' do
  import_pods
end

target 'SampleApp' do
  import_pods
end

target 'UnitTests' do
  import_pods
  import_test_pods
end

target 'Functional Specs' do
  import_pods
  import_test_pods
end


post_install do |installer|
  # we don't want to link static lib to the icucore dylib or it will fail to build
  builds = ['debug', 'release']

  builds.each do |build|
    installer.pods_project.targets.each do |target|
      config_file_path = File.join("Pods", "Target Support Files", "#{target.name}", "#{target.name}.#{build}.xcconfig")

      if File.file? config_file_path
        File.open("#{build}_config.tmp", "w") do |io|
          io << File.read(config_file_path).gsub(/-l"icucore"/, '')
        end

        FileUtils.mv("#{build}_config.tmp", config_file_path)
      end
    end
  end
end
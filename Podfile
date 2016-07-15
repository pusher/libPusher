# This podfile is intended for development on libPusher.
#
# If you are working on libPusher, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.

inhibit_all_warnings!
use_frameworks!

def import_pods
  pod 'Reachability', git: 'https://github.com/tonymillion/Reachability.git'
  pod 'SocketRocket', '~> 0.5'
end

def import_reactive_pod
  pod 'ReactiveCocoa', '~> 4.0'
end

def import_test_pods
  pod 'Kiwi', '~> 2.4'
  pod 'OHHTTPStubs', '~> 5.0'
end


target 'libPusher' do
  platform :ios, '8.0'
  import_pods
end

target 'libPusheriOS' do
  platform :ios, '8.0'
  import_pods
end

target 'libPusher-OSX' do
  platform :osx, '10.9'
  import_pods
end

target 'libPusher-tvOS' do
  platform :tvos, '9.0'
  import_pods
end

target 'libPushertvOS' do
  platform :tvos, '9.0'
  import_pods
end

target 'libPusher_ReactiveExtensions.a' do
  platform :ios, '8.0'
  import_pods
  import_reactive_pod
end

target 'SampleApp' do
  platform :ios, '8.0'
  import_pods
  import_reactive_pod
end

target 'SampleApp2' do
  platform :ios, '8.0'
  import_pods
  import_reactive_pod
end


target 'libPusher-ReactiveExtensions' do
  platform :ios, '8.0'
  import_pods
  import_reactive_pod
end


target 'SampleAppOSX' do
  platform :osx, '10.9'
  import_pods
end

target 'UnitTests' do
  platform :ios, '8.0'
  import_pods
  import_test_pods
end

target 'UnitTests-OSX' do
  platform :osx, '10.9'
  import_pods
  import_test_pods
end

target 'Functional Specs' do
  platform :ios, '8.0'
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
require 'bundler/setup'
require 'restclient'
require 'tempfile'
require 'xcode_build'
require 'xcode_build/tasks/build_task'
require 'xcode_build/formatters/progress_formatter'
require 'tmpdir'

LIBRARY_VERSION = "1.6.1"
XCODEBUILD_LOG  = File.join(File.dirname(__FILE__), "xcodebuild.log")
GITHUB_USER     = 'lukeredpath'
GITHUB_REPO     = 'libPusher'

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

task :docs => "docs:generate"

namespace :docs do
  def appledoc_cmd(output_dir)
    "appledoc \
      -t /usr/local/Cellar/appledoc/2.0.5/Templates \
      --no-search-undocumented-doc \
      --keep-intermediate-files \
      --docset-feed-url http://lukeredpath.github.com/libPusher/%DOCSETATOMFILENAME \
      --docset-package-url http://lukeredpath.github.com/libPusher/%DOCSETPACKAGEFILENAME \
      --publish-docset \
      --project-company 'Luke Redpath' \
      --company-id 'co.uk.lukeredpath' \
      --output #{output_dir} \
      --project-name libPusher \
      -v #{LIBRARY_VERSION}"
  end
  
  task :generate do
    system appledoc_cmd("Docs/API") << " Library/PT*"
  end
  
  task :install do
    system appledoc_cmd("Docs/API") << " --install-docset Library/PT*"
  end
  
  task :publish do
    tempdir = Dir.tmpdir + "/libPusherDocs"
    system appledoc_cmd(tempdir) << " Library/PT*"
    system "git checkout gh-pages"
    system "cp -r #{tempdir}/* ."
    system "cp publish/* . && rm -r publish"
    system "git add ."
    system "git commit -m 'Updated published docs'"
    system "git push origin gh-pages"
    system "git checkout master"
  end
end

XcodeBuild::Tasks::BuildTask.new(:debug) do |t|
  t.workspace = "libPusher.xcworkspace"
  t.scheme = "libPusher"
  t.configuration = "Debug"
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
  t.xcodebuild_log_path = XCODEBUILD_LOG
end

ARTEFACT_DIR = File.join("dist", "libPusher")

def copy_artefacts_from_build(build, options={})
  target = File.join(build.target_build_directory, "libPusher.a")
  destination = File.join(ARTEFACT_DIR, "libPusher-#{build.environment["SDK_NAME"]}.a")
  FileUtils.mv(target, destination)
  
  if options[:include_headers]
    header_dir = File.join(build.target_build_directory, "usr", "local", "include")
    FileUtils.mv(header_dir, File.join(ARTEFACT_DIR, "headers"))
  end
end

def combine_libraries(lib_paths, target)
  system "lipo -create #{lib_paths.map { |p| "\"#{p}\"" }.join(" ")} -output #{target}"
end

def current_git_commit_sha
  `git log --pretty=format:'%h' -n 1`.strip
end

def prepare_distribution_package(file_suffix, copy_readme = true)
  FileUtils.cp("README-DIST.txt", "dist/libPusher/README.txt") if copy_readme
  
  Dir.chdir("dist") do
    system "zip -r libPusher-#{file_suffix}.zip libPusher"
  end

  "dist/libPusher-#{file_suffix}.zip"
end

def unquote(string)
  string.gsub(/"/, '')
end

require 'github/downloads'
require 'osx_keychain'

def upload_package_to_github(file)
  puts "Skipping Github upload (no longer supported)"
  return
  
  keychain = OSXKeychain.new
  password = keychain['api.github.com', GITHUB_USER]
  uploader = Github::Downloads.connect(GITHUB_USER, password, GITHUB_REPO)
  
  begin
    uploader.create(file, "Built from #{current_git_commit_sha} at #{Time.now.strftime("%d/%m/%Y")}", :overwrite => true)
  rescue Github::Downloads::UnexpectedResponse => e
    puts "Unexpected response #{e}"
    puts "Error: #{e.error_message}"
    exit 1
  end
end

namespace :release do
  XcodeBuild::Tasks::BuildTask.new(:device) do |t|
    t.workspace = "libPusher.xcworkspace"
    t.scheme = "libPusher"
    t.configuration = "Release"
    t.sdk = "iphoneos"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.after_build { |build| copy_artefacts_from_build(build, :include_headers => true) }
    t.xcodebuild_log_path = XCODEBUILD_LOG
  end
  
  XcodeBuild::Tasks::BuildTask.new(:simulator) do |t|
    t.workspace = "libPusher.xcworkspace"
    t.scheme = "libPusher"
    t.configuration = "Release"
    t.sdk = "iphonesimulator"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.after_build { |build| copy_artefacts_from_build(build) }
    t.xcodebuild_log_path = XCODEBUILD_LOG
  end
  
  XcodeBuild::Tasks::BuildTask.new(:osx) do |t|
    t.project_name = "libPusher-OSX/libPusher-OSX.xcodeproj"
    t.target = "Pusher"
    t.configuration = "Release"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.after_build do |build| 
      Dir["#{unquote(build.target_build_directory)}/*.*"].each do |product|
        system %{cp -r "#{product}" "#{ARTEFACT_DIR}"}
      end
    end
    t.xcodebuild_log_path = XCODEBUILD_LOG
  end
  
  desc "Build combined release libraries for both device and simulator."
  task :combined => [:prepare_distribution, "release:device:cleanbuild", "release:simulator:cleanbuild"] do
    puts "Creating fat binary from simulator and device builds..."
    combine_libraries(Dir[File.join(ARTEFACT_DIR, "*.a")], File.join(ARTEFACT_DIR, "libPusher-combined.a"))
  end
  
  task :prepare_distribution do
    FileUtils.rm_rf("dist")
    FileUtils.mkdir_p(ARTEFACT_DIR)
  end
  
  desc "Build and package the iOS library for nightly distribution"
  task :nightly_ios => :combined do
    puts "Crreating iOS package for nightly distribution..."
    package_file = prepare_distribution_package("iOS-nightly")
    puts "Uploading package to Github..."
    upload_package_to_github(package_file)
    puts "Finished."
  end
  
  desc "Build and package the OSX framework for nightly distribution"
  task :nightly_osx => [:prepare_distribution, "osx:cleanbuild"] do
    puts "Crreating OSX package for nightly distribution..."
    package_file = prepare_distribution_package("OSX-nightly", false)
    puts "Uploading package to Github..."
    upload_package_to_github(package_file)
    puts "Finished."
  end
  
  desc "Build and package for stable iOS distribution"
  task :stable_ios => :combined do
    puts "Crreating package for #{LIBRARY_VERSION} distribution..."
    package_file = prepare_distribution_package("iOS-v#{LIBRARY_VERSION}")
    puts "Uploading package to Github..."
    upload_package_to_github(package_file)
    puts "Finished."
  end
  
  desc "Build and package for stable OSX distribution"
  task :stable_osx => [:prepare_distribution, "osx:cleanbuild"] do
    puts "Crreating package for #{LIBRARY_VERSION} distribution..."
    package_file = prepare_distribution_package("OSX-v#{LIBRARY_VERSION}")
    puts "Uploading package to Github..."
    upload_package_to_github(package_file)
    puts "Finished."
  end
  
  desc "Build, package and release iOS and OSX distribution"
  task :stable => [:stable_ios, :stable_osx]
end

namespace :test do
  XcodeBuild::Tasks::BuildTask.new do |t|
    t.workspace = "libPusher.xcworkspace"
    t.scheme = "UnitTests"
    t.configuration = "Debug"
    t.sdk = "iphonesimulator"
    t.arch = "i386"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.xcodebuild_log_path = XCODEBUILD_LOG
  end

  desc "Run unit tests"
  task :run => 'xcode:cleanbuild' do
    sh "bundle exec ios-sim-test logic --workspace=libPusher.xcworkspace --scheme=UnitTests --configuration=Debug"
  end
end

task :test => 'test:run'

require 'bundler/setup'
require 'restclient'
require 'tempfile'
require 'xcode_build'
require 'xcode_build/tasks/build_task'
require 'xcode_build/formatters/progress_formatter'

LIBRARY_VERSION = "1.0"

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
  def appledoc_cmd
    "appledoc \
      -t /usr/local/Cellar/appledoc/2.0.4/Templates \
      --no-search-undocumented-doc \
      --keep-intermediate-files \
      --verbose 1 \
      --project-company 'Luke Redpath' \
      --company-id 'co.uk.lukeredpath' \
      --output Docs/API \
      --project-name libPusher \
      -v #{LIBRARY_VERSION}"
  end
  
  task :generate do
    system appledoc_cmd << "Library/PT*"
  end
  
  task :install do
    system appledoc_cmd << " --install-docset Library/PT*"
  end
end

XcodeBuild::Tasks::BuildTask.new(:debug) do |t|
  t.workspace = "libPusher.xcworkspace"
  t.scheme = "libPusher"
  t.configuration = "Debug"
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
end

ARTEFACT_DIR = File.join("dist", "libPusher")

def copy_artefacts_from_build(build, options={})
  FileUtils.mkdir_p(ARTEFACT_DIR)
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

def prepare_distribution_package(file_suffix)
  FileUtils.cp("README-DIST.txt", "dist/libPusher/README.txt")
  
  Dir.chdir("dist") do
    system "zip -r libPusher-#{file_suffix}.zip libPusher"
  end

  "dist/libPusher-#{file_suffix}.zip"
end

require 'net/github-upload'

def upload_package_to_github(file)
  login = `git config github.user`.chomp
  token = `git config github.token`.chomp 
  
  upload = Net::GitHub::Upload.new(login: login, token: token)
  upload.replace(
           repos: "libPusher",
            file: file,
     description: "Nightly automated build, SHA #{current_git_commit_sha} (#{Time.now.strftime("%d/%m/%Y")})"
  )
end

namespace :release do
  XcodeBuild::Tasks::BuildTask.new(:device) do |t|
    t.workspace = "libPusher.xcworkspace"
    t.scheme = "libPusher"
    t.configuration = "Release"
    t.sdk = "iphoneos"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.after_build { |build| copy_artefacts_from_build(build, include_headers: true) }
  end
  
  XcodeBuild::Tasks::BuildTask.new(:simulator) do |t|
    t.workspace = "libPusher.xcworkspace"
    t.scheme = "libPusher"
    t.configuration = "Release"
    t.sdk = "iphonesimulator"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    t.after_build { |build| copy_artefacts_from_build(build) }
  end
  
  desc "Build combined release libraries for both device and simulator."
  task :combined => [:prepare_distribution, "release:device:cleanbuild", "release:simulator:cleanbuild"] do
    puts "Creating fat binary from simulator and device builds..."
    combine_libraries(Dir[File.join(ARTEFACT_DIR, "*.a")], File.join(ARTEFACT_DIR, "libPusher-combined.a"))
  end
  
  task :prepare_distribution do
    FileUtils.rm_rf("dist")
  end
  
  desc "Build and package for nightly distribution"
  task :nightly => :combined do
    puts "Crreating package for nightly distribution..."
    package_fie = prepare_distribution_package("nightly")
    puts "Uploading package to Github..."
    upload_package_to_github(package_fie)
    puts "Finished."
  end
end

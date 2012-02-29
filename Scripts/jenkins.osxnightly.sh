export TERM=xterm
./Scripts/update-pods.sh
bundle exec rake release:nightly_osx


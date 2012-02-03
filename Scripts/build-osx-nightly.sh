#!/bin/sh 
echo "*****************************"
echo "PREPARING FOR BUILD"
echo "*****************************"

source "$HOME/.rvm/scripts/rvm"

echo "* Updating gems for MRI"
rvm use default
bundle install --without macruby 
echo ""

bundle exec rake release:nightly_osx

#!/bin/sh 
echo "*****************************"
echo "PREPARING FOR BUILD"
echo "*****************************"

echo "* Updating gems for MRI"
rvm use default
bundle install --without macruby 
echo ""

bundle exec rake release:nightly_osx

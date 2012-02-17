#!/bin/sh 
source "$HOME/.rvm/scripts/rvm"

echo "*****************************"
echo "UPDATING PROJECT DEPENDENCIES "
echo "*****************************"

echo "* Updating gems"
bundle install > /dev/null

echo "* Updating CocoaPods"
bundle exec pod install > /dev/null
echo ""

echo "*****************************"
echo "PREPARING FOR BUILD"
echo "*****************************"
echo ""

bundle exec rake release:nightly_ios

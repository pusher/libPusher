#!/bin/sh
if [ -f "$HOME/.rvm/scripts/rvm" ] 
  then
  source "$HOME/.rvm/scripts/rvm"
fi
bundle install
# rm -fr Pods
bundle exec pod install

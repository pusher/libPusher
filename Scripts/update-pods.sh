#!/bin/sh
source "$HOME/.rvm/scripts/rvm"
bundle install
rm -fr Pods
bundle exec pod install

#!/bin/bash -e
source "$HOME/.rvm/scripts/rvm"
rvm use default
bundle install
rake

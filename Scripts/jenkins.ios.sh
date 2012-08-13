#!/bin/zsh
source "$HOME/.zshenv"
export TERM=xterm
bundle exec rake release:combined

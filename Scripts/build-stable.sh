#!/bin/sh
sh Scripts/update-pods.sh
bundle exec rake release:stable

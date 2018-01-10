#!/bin/bash

sudo apt update
sudo apt install -y build-essential ruby-full ruby-bundler
## if [ ! $(ruby -v && bundle -v) | grep -ei (ruby|Bundler) == '' ]; then
	exit 1
fi
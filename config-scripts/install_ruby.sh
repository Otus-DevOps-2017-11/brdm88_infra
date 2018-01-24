#!/bin/bash

set -e

echo "-----------------------------------------------------------------"
echo `date`: "Installing Ruby..."
sudo apt update && sudo apt install -y build-essential ruby-full ruby-bundler

echo "================================================================="
echo "Checking installed Ruby & Bundle versions..."
ruby -v
bundle -v
echo "Script execution completed!"

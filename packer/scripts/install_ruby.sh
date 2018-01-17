#!/bin/bash

set -e

echo "-----------------------------------------------------------------"
echo `date`: "Installing Ruby..."
apt update && apt install -y build-essential ruby-full ruby-bundler

echo "================================================================="
echo "Checking installed Ruby & Bundle versions..."
ruby -v
bundle -v
echo "Script execution completed!"

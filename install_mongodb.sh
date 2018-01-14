#!/bin/bash

set -e

echo "-----------------------------------------------------------------"
echo `date`: "Installing MongoDB..."

# Add key and repo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

# Perform the install
sudo apt update
sudo apt install -y mongodb-org

# Start and enable service
sudo systemctl start mongod
sudo systemctl enable mongod

echo "================================================================="
echo "Checking MongoDB daemon..."
sudo systemctl status mongod

echo "Script execution completed!"

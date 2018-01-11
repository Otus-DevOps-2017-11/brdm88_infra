#!/bin/bash

echo "-----------------------------------------------------------------"
echo `date`: "Installing MongoDB..."

# Add key and repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

# Perform the install
apt update
apt install -y mongodb-org

# Start and enable service
systemctl start mongod
systemctl enable mongod

echo "================================================================="
echo "Checking MongoDB daemon..."
systemctl status mongod

echo "Script execution completed!"

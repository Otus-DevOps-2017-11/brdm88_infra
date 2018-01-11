#!/bin/bash

echo "-----------------------------------------------------------------"
echo "Getting and installing the App..."
cd /opt
sudo git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install

echo "Starting the app..."
puma -d
sleep 3
ps aux | grep puma

echo "Script completed!"

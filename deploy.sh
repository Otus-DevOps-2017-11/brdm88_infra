#!/bin/bash

install_dir=/opt

echo "-----------------------------------------------------------------"
echo `date`: "Getting and installing the REddit application..."
cd $install_dir
sudo git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install

echo "Starting the app..."
puma -d
sleep 3
ps aux | grep puma

echo "Script execution completed!"

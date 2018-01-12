#!/bin/bash

install_dir=/opt

# Get the application source code and make install
echo "-----------------------------------------------------------------"
echo `date`: "Getting and installing the Reddit application..."
cd $install_dir
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install

# Enable & start the puma service (config file is to be previously copied by provisioner)
systemctl daemon-reload
systemctl enable puma
systemctl start puma
systemctl status puma

echo "Script execution completed!"
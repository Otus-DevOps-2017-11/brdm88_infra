#!/bin/bash

set -e

logfile=/var/log/reddit_deploy.log
install_dir=/opt

echo "-----------------------------------------------------------------" >> $logfile
echo `date`: "Installing Ruby..." >> $logfile
sudo apt update && sudo apt install -y build-essential ruby-full ruby-bundler >> $logfile

echo "=================================================================" >> $logfile
echo "Checking installed Ruby & Bundle versions..." >> $logfile
ruby -v >> $logfile
bundle -v >> $logfile

#########################################################################################

echo "Installing MongoDB..." >> $logfile

# Add key and repo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 >> $logfile
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list' >> $logfile

# Perform the install
sudo apt update >> $logfile
sudo apt install -y mongodb-org >> $logfile

# Start and enable service
sudo systemctl start mongod >> $logfile
sudo systemctl enable mongod >> $logfile

echo "=================================================================" >> $logfile
echo "Checking MongoDB daemon..." >> $logfile
sudo systemctl status mongod >> $logfile

#########################################################################################

echo "-----------------------------------------------------------------" >> $logfile
echo `date`: "Getting and installing the Reddit application..." >> $logfile
cd $install_dir
sudo git clone https://github.com/Otus-DevOps-2017-11/reddit.git >> $logfile
cd reddit && bundle install >> $logfile

echo "Starting the app..." >> $logfile
puma -d >> $logfile
sleep 3
ps aux | grep puma >> $logfile

echo `date`: "Startup script execution completed!" >> $logfile
echo "=================================================================" >> $logfile

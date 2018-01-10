#!/bin/bash

git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install
puma -d
ps aux | grep puma

################### gcloud command - create

gcloud compute instances create reddit-app\ 
  --boot-disk-size=10GB \ 
  --image-family ubuntu-1604-lts \ 
  --image-project=ubuntu-os-cloud \ 
  --machine-type=g1-small \ 
  --tags puma-server \ 
  --restart-on-failure
  
  
##### Startup script

gcloud compute instance-templates create python-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --tags http-server \
  --machine-type=f1-micro \
  --restart-on-failure \
--metadata startup-script='wget -O run_app.sh | bash'

############ Firewall rule
gcloud compute firewall-rules create default-puma-server \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:9292 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=puma-server
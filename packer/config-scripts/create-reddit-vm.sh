#!/bin/bash

# Create Reddit app VM from baked image
echo "Creating VM from baked image..."

gcloud compute instances create reddit-app-baked \
  --zone=europe-west1-b \
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
  
echo "Instance creation command completed!"
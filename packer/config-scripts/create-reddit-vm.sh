#!/bin/bash

# Create Reddit app VM from baked image
echo "Creating VM from baked image..."

gcloud compute instances create reddit-app-baked \
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure
  
echo "Instance creation command completed!"
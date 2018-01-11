################## gcloud command - create

gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
  
gcloud compute instances create "reddit-full" \
--zone "europe-west1-b" \
--machine-type "g1-small" \
--subnet "default" \
--tags "puma-server" \ 
--image "" \
--image-project "" \
--boot-disk-size "10" \
--boot-disk-type "pd-standard" \
--boot-disk-device-name "reddit-full" \
--restart-on-failure

gcloud compute \
--project $GCP_PROJECT_ID instances create "instance-$TIMESTAMP" \
--zone "europe-west1-b" \
--machine-type "g1-small" \
--subnet "default" \
--maintenance-policy "MIGRATE" \
--service-account "380934741266-compute@developer.gserviceaccount.com" \
--scopes \
"https://www.googleapis.com/auth/devstorage.read_only",\
"https://www.googleapis.com/auth/logging.write",\
"https://www.googleapis.com/auth/monitoring.write",\
"https://www.googleapis.com/auth/servicecontrol",\
"https://www.googleapis.com/auth/service.management.readonly",\
"https://www.googleapis.com/auth/trace.append" \
--min-cpu-platform "Automatic" \
--tags "puma-server" \
--image-family "reddit-full" \
--image-project $GCP_PROJECT_ID \
--boot-disk-device-name "instance-$TIMESTAMP"

gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family=$IMAGE_FAMILY \
  --image-project=$PROJECT_NAME \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
--zone=europe-west1-b

PROJECT_NAME="infra-188905"
IMAGE_FAMILY="reddit-full"

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
# Define Google Cloud provider

provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

# Define remote backend for state file storage

terraform {
  backend "gcs" {
    bucket = "tf-state-backend"
    prefix = "terraform/prod"
  }
}

# Modules definition

module "app" {
  source = "../modules/app"

  project_ssh_user  = "${var.project_ssh_user}"
  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  region_zone       = "${var.region_zone}"
  machine_type      = "${var.machine_type}"
  app_instance_name = "${var.app_instance_name}"
  app_disk_image    = "${var.app_disk_image}"
  app_port          = "${var.app_port}"
  app_user          = "${var.app_user}"
  app_workdir       = "${var.app_workdir}"
  deploy_by_tf      = "${var.deploy_by_tf}"
  app_network_tags  = "${var.app_network_tags}"

  # Connect to database server using internal ip address
  database_url = "${module.db.db_internal_ip}:27017"
}

module "db" {
  source = "../modules/db"

  project_ssh_user = "${var.project_ssh_user}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  region_zone      = "${var.region_zone}"
  machine_type     = "${var.machine_type}"
  db_instance_name = "${var.db_instance_name}"
  db_disk_image    = "${var.db_disk_image}"
  deploy_by_tf     = "${var.deploy_by_tf}"
}

module "vpc" {
  source = "../modules/vpc"

  project_ssh_user    = "${var.project_ssh_user}"
  project_pubkey_path = "${var.project_pubkey_path}"
  source_ranges       = "${var.ssh_source_ranges}"
}

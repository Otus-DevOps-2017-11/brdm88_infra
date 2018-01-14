# Define Google Cloud provider

provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

# Modules definition

module "app" {
  source          = "../modules/app"
  public_key_path = "${var.public_key_path}"
  region_zone     = "${var.region_zone}"
  app_disk_image  = "${var.app_disk_image}"
}

module "db" {
  source          = "../modules/db"
  public_key_path = "${var.public_key_path}"
  region_zone     = "${var.region_zone}"
  db_disk_image   = "${var.db_disk_image}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = "${var.source_ranges}"
}

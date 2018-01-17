
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_storage_bucket" "tf-state-stage" {
  name     = "brdm88-tf-state-stage"
  location = "${var.region_zone}"
}

terraform {
  backend "gcs" {
    bucket  = "brdm88-tf-state-stage"
    #key = "main-tier/remote_state"
    region = "europe-west1"
    prefix    = "terraform.tfstate"
  }
}

##

/*
data "terraform_remote_state" "foo" {
  backend = "gcs"
  config {
    bucket  = "terraform-state"
    prefix  = "stage"
  }
}

resource "template_file" "bar" {
  template = "${greeting}"

  vars {
    greeting = "${data.terraform_remote_state.foo.greeting}"
  }
}
*/

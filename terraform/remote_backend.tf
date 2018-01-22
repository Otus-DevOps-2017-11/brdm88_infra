
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

/*
resource "google_storage_bucket" "tf-state-stage" {
  name     = "brdm88-tf-state-stage"
  location = "${var.region_zone}"
}
*/

terraform {
  backend "gcs" {
    bucket  = "tf-state-backend"
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

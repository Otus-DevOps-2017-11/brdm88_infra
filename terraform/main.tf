# Define Google Cloud provider

provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

# Define the Instance resource created from base image

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  tags = ["reddit-app"]

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  # Connection for the provisioners
  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  # Define the app deploying provisioners
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

# Define firewall rule resource

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

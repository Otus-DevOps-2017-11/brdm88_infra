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
    prefix = "terraform/stage_clean"
  }
}

# Define external IP

#resource "google_compute_address" "app_ip" {
#  name = "reddit-app-ip"
#}

# Create VM instance for App server

resource "google_compute_instance" "app" {
  name = "${var.app_instance_name}"

  machine_type = "${var.machine_type}"

  zone = "${var.region_zone}"

  tags = ["reddit-app", "http-server"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      #      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    sshKeys = "${var.project_ssh_user}:${file(var.public_key_path)}"
  }
}

# Add firewall rule to allow access to application at port 9292

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["reddit-app"]
}

# Create VM instance for DB server

resource "google_compute_instance" "db" {
  name = "${var.db_instance_name}"

  machine_type = "${var.machine_type}"

  zone = "${var.region_zone}"

  tags = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {}
  }

  metadata {
    sshKeys = "${var.project_ssh_user}:${file(var.public_key_path)}"
  }
}

# Add firewall rule allowing access to DB from app server

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}

# Definition of firewall rule for SSH access from certain network

resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh"
  description = "Allow SSH access from certain ranges"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Definition of project-wide public ssh keys

resource "google_compute_project_metadata" "project_ssh_keys" {
  metadata {
    # Personal key setting
    ssh-keys = "${var.project_ssh_user}:${file(var.project_pubkey_path)}"
  }
}

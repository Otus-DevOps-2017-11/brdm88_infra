# Create VM instance for DB server

# Case 1: deploy application using Terraform

resource "google_compute_instance" "db_depl" {

  count = "${var.deploy_by_tf}"

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

  # Connection for the provisioners
  connection {
    type        = "ssh"
    user        = "${var.project_ssh_user}"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  # Define the database config deploying provisioners

  # Change bindIp from default "127.0.0.1" to "0.0.0.0" in /etc/mongod.conf file using sed and restart MongoDB
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}

# Case 2: DO NOT deploy application by Terraform

resource "google_compute_instance" "db" {
  
  count = "${1 - var.deploy_by_tf}"
  
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

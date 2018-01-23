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

# Define template provider to configure puma.service unit file

data "template_file" "puma_unitfile" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    app_user     = "${var.app_user}"
    app_workdir  = "${var.app_workdir}"
    app_port     = "${var.app_port}"
    database_url = "${var.database_url}"
  }
}

# Define external IP

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

# Create VM instance for DB server

resource "google_compute_instance" "app" {
  name = "${var.app_instance_name}"

  machine_type = "${var.machine_type}"

  zone = "${var.region_zone}"

  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
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

  # Define the application deploying provisioners

  # Generate systemd unit file from the template
  provisioner "file" {
    content     = "${data.template_file.puma_unitfile.rendered}"
    destination = "/tmp/puma.service"
  }
  # Execute the deploy script
  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}

# Add firewall rule to allow access to application

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.app_port}"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["reddit-app"]
}

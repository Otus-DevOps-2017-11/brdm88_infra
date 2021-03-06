# Define Google Cloud provider

provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

## Additional task 1 code: project-wide ssh keys
################################################

# Add project-wide ssh keys

resource "google_compute_project_metadata" "project_ssh_keys" {
  metadata {
    #ssh-keys = "appuser:${file(var.project_pubkey_path)}appuser2:${file(var.project_pubkey_path)}"

    # Personal key setting
    ssh-keys = "${var.project_ssh_user}:${file(var.project_pubkey_path)}"
  }
}

# Define the Instance creatinon from base image

resource "google_compute_instance" "app" {
  count = "${var.nodes_count}"

  name         = "reddit-app-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

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
    sshKeys = "${var.project_ssh_user}:${file(var.public_key_path)}"
  }

  # Connection for the provisioners
  connection {
    type        = "ssh"
    user        = "${var.project_ssh_user}"
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

# Define firewall rules resource

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

resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh"
  description = "Allow SSH access from anywhere"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

## Additional task 2 code: creating HTTP balancer
#################################################

# Create instance group for backend puma servers
resource "google_compute_instance_group" "puma-backends" {
  name = "puma-reddit-backends"
  zone = "${var.region_zone}"

  instances = ["${google_compute_instance.app.*.self_link}"]

  named_port {
    name = "puma-http"
    port = "9292"
  }
}

# Create health check - port http:9292
resource "google_compute_http_health_check" "puma-http-healthcheck" {
  name               = "reddit-puma-http-healthcheck"
  port               = "9292"
  request_path       = "/"
  check_interval_sec = 3
  timeout_sec        = 2
}

# Create backend service for load balancing
resource "google_compute_backend_service" "puma-backend-lb" {
  name        = "reddit-puma-backend-lb"
  protocol    = "HTTP"
  timeout_sec = 10
  port_name   = "puma-http"

  #session_affinity = "CLIENT_IP"

  # Set created instance group as a backend
  backend {
    group = "${google_compute_instance_group.puma-backends.self_link}"
  }
  # Define created healthcheck
  health_checks = ["${google_compute_http_health_check.puma-http-healthcheck.self_link}"]
}

# Create URL map
resource "google_compute_url_map" "puma-url-map" {
  name            = "reddit-puma-url-map"
  default_service = "${google_compute_backend_service.puma-backend-lb.self_link}"
}

# Create target http proxy
resource "google_compute_target_http_proxy" "puma-http-proxy" {
  name    = "reddit-puma-http-proxy"
  url_map = "${google_compute_url_map.puma-url-map.self_link}"
}

# Create global forwarding rule
resource "google_compute_global_forwarding_rule" "puma-forwarding-rule" {
  name       = "reddit-puma-forwarding-rule"
  target     = "${google_compute_target_http_proxy.puma-http-proxy.self_link}"
  port_range = "80"
}

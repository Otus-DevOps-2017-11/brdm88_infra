# Definition of firewall rule for SSH access from certain network

resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh"
  description = "Allow SSH access from certain ranges"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = "${var.ssh_port}"
  }

  source_ranges = "${var.source_ranges}"
}

# Definition of project-wide public ssh keys

resource "google_compute_project_metadata" "project_ssh_keys" {
  metadata {
    # Personal key setting
    ssh-keys = "${var.project_ssh_user}:${file(var.project_pubkey_path)}"
  }
}

output "ssh_allowed_networks" {
  value = "${google_compute_firewall.firewall_ssh.source_ranges}"
}

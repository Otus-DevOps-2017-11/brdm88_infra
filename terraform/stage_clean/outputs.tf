# Define output variables returned by used moudules

output "app_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "db_internal_ip" {
  value = "${google_compute_instance.db.network_interface.0.address}"
}

output "db_external_ip" {
  value = "${google_compute_instance.db.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "ssh_allowed_networks" {
  value = "${google_compute_firewall.firewall_ssh.source_ranges}"
}

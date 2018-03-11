# Output - DB server internal and external IP addresses

output "db_internal_ip" {
  value = "${coalesce(join("",google_compute_instance.db_depl.*.network_interface.0.address), join("", google_compute_instance.db.*.network_interface.0.address))}"
}


output "db_external_ip" {
  value = "${coalesce(join("", google_compute_instance.db_depl.*.network_interface.0.access_config.0.assigned_nat_ip), join("", google_compute_instance.db.*.network_interface.0.access_config.0.assigned_nat_ip))}"
}

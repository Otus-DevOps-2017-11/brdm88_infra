# Define app server external IP address output

output "app_external_ip" {
  value = "${coalesce(join("", google_compute_instance.app_depl.*.network_interface.0.access_config.0.assigned_nat_ip), join("", google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip))}"
}

output "app_http_port" {
  value = "${var.app_port}"
}

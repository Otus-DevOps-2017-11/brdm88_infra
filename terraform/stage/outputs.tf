# Define output variables returned by used moudules

output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_internal_ip" {
  value = "${module.db.db_internal_ip}"
}

output "db_external_ip" {
  value = "${module.db.db_external_ip}"
}

output "ssh_allowed_networks" {
  value = "${module.vpc.ssh_allowed_networks}"
}

output "ssh_port" {
  value = "${module.vpc.ssh_port}"
}

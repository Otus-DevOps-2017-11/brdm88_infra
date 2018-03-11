# Define output variables returned by used modules

output "app_deploy_by_terraform" {
  value = "${var.deploy_by_tf}"
}

output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "app_http_port" {
  value = "${module.app.app_http_port}"
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

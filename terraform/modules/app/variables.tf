variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private_key used for ssh access"
}

variable project_ssh_user {
  description = "User name for ssh access (project-wide)"
  default     = "brdm88"
}

variable region_zone {
  description = "Instance geographical zone"
  default     = "europe-west1-b"
}

variable machine_type {
  description = "GCE virtual machine type"
  default     = "g1-small"
}

variable app_instance_name {
  description = "Application VM instance name"
  default     = "reddit-app"
}

variable app_disk_image {
  description = "Reddit App disk image"
  default     = "reddit-app-base"
}

variable app_port {
  description = "Reddit application HTTP port"
  default     = "9292"
}

variable app_user {
  description = "Reddit application user"
  default     = "brdm88"
}

variable app_workdir {
  description = "Reddit application working directory"
}

variable database_url {
  description = "Database URL for reddit application"
}

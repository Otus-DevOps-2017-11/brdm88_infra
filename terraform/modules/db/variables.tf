variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable project_ssh_user {
  description = "User name for ssh access (project-wide)"
  default     = "brdm88"
}

variable region_zone {
  description = "Instance geographical zone"
  default     = "europe-west1-b"
}

variable db_disk_image {
  description = "Reddit App disk image"
  default     = "reddit-db-base"
}

variable machine_type {
  description = "GCE virtual machine type"
  default     = "g1-small"
}

variable db_instance_name {
  description = "Database VM instance name"
  default = "reddit-db"
}

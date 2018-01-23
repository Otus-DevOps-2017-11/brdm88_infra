# Common vars

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable project_pubkey_path {
  description = "Project-wide ssh public key"
}

variable project_ssh_user {
  description = "User name for ssh access (project-wide)"
  default     = "brdm88"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private_key used for ssh access"
}

variable region_zone {
  description = "Instance geographical zone"
  default     = "europe-west1-b"
}

variable machine_type {
  description = "GCE virtual machine type"
  default     = "g1-small"
}

# App associated vars

variable app_instance_name {
  description = "Application VM instance name"
  default = "reddit-app"
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
  default     = "/opt"
}

# DB associated vars

variable db_instance_name {
  description = "Database VM instance name"
  default = "reddit-db"
}

variable db_disk_image {
  description = "Reddit App disk image"
  default     = "reddit-db-base"
}

# SSH associated vars

variable ssh_source_ranges {
  description = "Allowed source IPs for SSH access"
  default     = ["0.0.0.0/0"]
}

variable ssh_port {
  description = "SSH allowed port"
  default     = ["22"]
}

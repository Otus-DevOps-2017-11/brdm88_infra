variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private_key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable region_zone {
  description = "Instance geographical zone"
  default     = "europe-west1-b"
}

variable machine_type {
  description = "GCE virtual machine type"
  default     = "g1-small"
}

# Variables for additional tasks

variable project_pubkey_path {
  description = "Project-wide ssh public key"
}

variable project_ssh_user {
  description = "User name for ssh access (project-wide)"
  default     = "brdm88"
}

variable nodes_count {
  description = "Application backend nodes count"
  default     = "1"
}

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

variable region_zone {
  description = "Instance geographical zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Reddit App disk image"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Reddit App disk image"
  default     = "reddit-db-base"
}

variable source_ranges {
  description = "Allowed source IPs for SSH access"
  default     = ["0.0.0.0/0"]
}

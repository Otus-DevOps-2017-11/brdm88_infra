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

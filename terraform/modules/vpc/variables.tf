variable project_pubkey_path {
  description = "Project-wide ssh public key"
}

variable project_ssh_user {
  description = "User name for ssh access (project-wide)"
  default     = "brdm88"
}

variable source_ranges {
  description = "Allowed source IPs for SSH access"
  default     = ["0.0.0.0/0"]
}

variable ssh_port {
  description = "SSH allowed port"
  default     = ["22"]
}

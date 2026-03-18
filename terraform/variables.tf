variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "ssh_public_key_path" {
  type = string
}

variable "my_ip_cidr" {
  type = string
}

variable "yc_token" {
  type      = string
  sensitive = true
}

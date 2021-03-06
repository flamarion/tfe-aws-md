# Load Balance Ports
variable "https_port" {
  type    = number
  default = 443
}

variable "https_proto" {
  type    = string
  default = "HTTPS"
}

variable "replicated_port" {
  type    = number
  default = 8800
}

variable "replicated_proto" {
  type    = string
  default = "HTTPS"
}

# Instances
variable "cloud_pub" {
  description = "SSH Public key pair"
  type        = string
}

variable "ebs_device_name" {
  description = "EBS volume device name"
  type        = string
  default     = "/dev/sdf"
}

variable "ebs_mount_point" {
  description = "EBS volume mount point"
  type        = string
  default     = "/opt/tfe"
}

variable "ebs_file_system" {
  description = "EBS volume filesystem"
  type        = string
  default     = "xfs"
}

# App variables

variable "dns_record_name" {
  type    = string
  default = "flamarion-md"
}

variable "admin_password" {
  type    = string
  default = "SuperS3cret"
}

variable "rel_seq" {
  type    = number
  default = 0
}

# General
variable "owner" {
  description = "Prefix for all tags and names"
  type        = string
  default     = "fj"
}


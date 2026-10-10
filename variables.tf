variable "aws_region" {
  description = "AWS region in which to create the network."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags."
  type        = string
  default     = "three-tier"

  validation {
    condition     = length(trimspace(var.name_prefix)) > 0
    error_message = "name_prefix must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "management_subnet_cidr" {
  description = "IPv4 CIDR block for the public Management subnet."
  type        = string
  default     = "10.1.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.management_subnet_cidr)) && endswith(var.management_subnet_cidr, "/24")
    error_message = "management_subnet_cidr must be a valid /24 IPv4 CIDR block."
  }
}

variable "application_subnet_cidr" {
  description = "IPv4 CIDR block for the private Application subnet."
  type        = string
  default     = "10.1.2.0/24"

  validation {
    condition     = can(cidrnetmask(var.application_subnet_cidr)) && endswith(var.application_subnet_cidr, "/24")
    error_message = "application_subnet_cidr must be a valid /24 IPv4 CIDR block."
  }
}

variable "backend_subnet_cidr" {
  description = "IPv4 CIDR block for the private Backend subnet."
  type        = string
  default     = "10.1.3.0/24"

  validation {
    condition     = can(cidrnetmask(var.backend_subnet_cidr)) && endswith(var.backend_subnet_cidr, "/24")
    error_message = "backend_subnet_cidr must be a valid /24 IPv4 CIDR block."
  }
}

variable "bastion_allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the bastion"
  type        = string
}

variable "bastion_ssh_public_key" {
  description = "Public key installed on the bastion for admin SSH access."
  type        = string
  sensitive   = true
}
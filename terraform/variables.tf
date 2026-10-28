variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Name prefix for all resources"
  type        = string
  default     = "order-system"
}

variable "vpc_cidr" {
  description = "IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_cidr" {
  description = "Your public IP as a /32, allowed to reach the Kubernetes API (port 6443)"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && endswith(var.admin_cidr, "/32")
    error_message = "admin_cidr must be a single IP in CIDR form, for example 203.0.113.10/32."
  }
}

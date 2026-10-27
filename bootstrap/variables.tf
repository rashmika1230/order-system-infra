variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address that receives budget alerts"
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly cost limit in USD that alerts are based on"
  type        = number
  default     = 30
}

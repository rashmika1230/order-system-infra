provider "aws" {
  region = var.aws_region

  # Applied to every resource this provider creates
  default_tags {
    tags = {
      Project   = "order-system"
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}

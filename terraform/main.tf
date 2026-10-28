data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  # use1-az3 is an older us-east-1 zone that doesn't offer many current instance types.
  # Zone IDs are the same in every account (zone NAMES like "us-east-1a" are shuffled per account).
  exclude_zone_ids = ["use1-az3"]
}

locals {
  # Two AZs are enough: RDS needs at least two for its subnet group
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # { "us-east-1a" = 0, "us-east-1b" = 1 }: used to give each subnet a unique CIDR
  az_index = { for i, az in local.azs : az => i }
}

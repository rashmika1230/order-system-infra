data "aws_caller_identity" "current" {}

# The availability zones we can use in this region (needed for subnets in Block 8)
data "aws_availability_zones" "available" {
  state = "available"
}

output "state_bucket_name" {
  description = "Use this bucket in the main configuration's backend block"
  value       = aws_s3_bucket.tfstate.bucket
}

output "aws_region" {
  value = var.aws_region
}

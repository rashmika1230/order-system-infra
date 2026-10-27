data "aws_caller_identity" "current" {}

locals {
  # S3 bucket names are global across ALL AWS accounts, so add the account ID to make it unique
  state_bucket_name = "order-system-tfstate-${data.aws_caller_identity.current.account_id}"
}

# ---------- Terraform state bucket ----------

resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket_name

  # Learning account only: allows deleting the bucket with its contents at final teardown.
  # In a real company you would use lifecycle { prevent_destroy = true } instead.
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled" # every state change is kept, so a bad change can be rolled back
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- Cost guardrail ----------

resource "aws_budgets_budget" "monthly" {
  name         = "order-system-monthly"
  budget_type  = "COST"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_types {
    # Measure usage BEFORE credits are applied. With credits included,
    # your bill shows $0 and the alert would never fire until the credits run out.
    include_credit = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

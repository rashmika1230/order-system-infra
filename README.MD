# order-system-infra

Terraform for the Order System on AWS (ap-south-1).

- `bootstrap/`: one-time setup: S3 bucket for Terraform state and a monthly budget alert (local state)
- `terraform/`: the main infrastructure (state stored in the bootstrap bucket)

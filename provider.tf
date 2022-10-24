provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "terraform-aws-eks-spot-attribute-workers"
      Owner   = "kjenney"
    }
  }

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project = "terraform-aws-eks-spot-attribute-workers"
    }
  }

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  name   = "ex-asg-complete"
  region = "us-east-1"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  user_data = <<-EOT
  #!/bin/bash
  set -o xtrace
  /etc/eks/bootstrap.sh example
  EOT
}

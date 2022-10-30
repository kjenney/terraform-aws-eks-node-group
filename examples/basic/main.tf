terraform {
  required_version = "= 0.13.7"
}

provider "aws" {
  region  = local.region
}

provider "random" {
  version = "~> 2.1"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name  = "test-eks-${random_string.suffix.result}"
  region        = "us-east-1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

################################################################################
# Basic Example
################################################################################
module "basic" {
  source                      = "../../"
  go_turbo                    = false
  vpc_id                      = module.vpc.vpc_id
  allowed_security_groups     = [module.eks_sg_basic.security_group_id]
  subnet_ids                  = module.vpc.private_subnets
  desired_capacity            = 1
  min_size                    = 1
  max_size                    = 2
  cluster_name                = local.cluster_name
  kubernetes_version          = "1.23"
  eks_cluster_endpoint        = aws_eks_cluster.example.endpoint
  eks_cluster_auth_token      = data.aws_eks_cluster_auth.example.token
  eks_cluster_ca_certificate  = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
}
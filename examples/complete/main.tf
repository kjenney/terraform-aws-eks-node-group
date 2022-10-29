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

module "eks_node_group" {
  source                      = "../../"
  instance_requirements = {
    memory_gib_per_vcpu = {
      min = 2
      max = 4
    }

    memory_mib = {
      min = 2048
      max = 32768
    }

    network_interface_count = {
      min = 1
      max = 16
    }

    vcpu_count = {
      min = 2
      max = 4
    }
  }

  network_interfaces = [
    {
      delete_on_termination   = true
      description             = "eth0"
      device_index            = 0
    },
    {
      delete_on_termination   = true
      description             = "eth1"
      device_index            = 1
    }
  ]
  
  mixed_instances_policy = {
    instances_distribution = {
      on_demand_base_capacity                   = 0
      on_demand_percentage_above_base_capacity  = 10
      spot_allocation_strategy                  = "capacity-optimized"
      spot_instance_pools                       = 0
    }
  }

  use_mixed_instances_policy  = true
  capacity_rebalance          = true
  vpc_zone_identifier         = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  allowed_security_groups     = [module.eks_sg.security_group_id]
  min_size                    = 1
  max_size                    = 2
  cluster_name                = local.cluster_name
  kubernetes_version          = "1.23"
  eks_cluster_endpoint        = aws_eks_cluster.example.endpoint
  eks_cluster_auth_token      = data.aws_eks_cluster_auth.example.token
  eks_cluster_ca_certificate  = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
}
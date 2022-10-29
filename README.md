# terraform-aws-eks-node-group

A Terraform module to create an EKS node group that uses an autoscaling group.

## IMPORTANT

This module allows the use of instance attributes and mixed instance policies with Spot for EKS nodes. 
<br>However, currently this requires a separate launch template and the use of aws_autoscaling_group rather than a eks_node_group resource.
<br>Watch https://github.com/aws/containers-roadmap/issues/1297 and update this module accordingly.

## Requirements

* VPC
* EKS Cluster
* Security Groups (for incoming traffic, etc)


## Example

```
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
```

## Inputs

We are using the `terraform-aws-autoscaling` module for the node group ASG where mixed instance policies are required. For a list of Inputs go to https://github.com/terraform-aws-modules/terraform-aws-autoscaling#inputs.

Module-specific inputs are:

cluster_name
eks_cluster_endpoint
eks_cluster_auth_token
eks_cluster_ca_certificate
allowed_security_groups
kubernetes_versions
wait_for_cluster_cmd
wait_for_cluster_interpreter

## Outputs

We are using the `terraform-aws-autoscaling` module for the node group ASG where mixed instance policies are required. For a list of Outputs go to https://github.com/terraform-aws-modules/terraform-aws-autoscaling#outputs.
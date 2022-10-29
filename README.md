# terraform-aws-eks-node-group

A Terraform module to create an EKS node group that uses an autoscaling group.

## IMPORTANT

This module allows the use of instance attributes and mixed instance policies with Spot for EKS nodes. 
<br>However, currently this requires a separate launch template and the use of aws_autoscaling_group rather than a eks_node_group resource.
<br>Watch https://github.com/aws/containers-roadmap/issues/1297 and update this module accordingly.

## Spot
This module uses instance attributes to prodvide a wider swath of instances to choose from so that a cluster will remain stable for longer periods of time.

## Requirements

* VPC
* EKS Cluster
* Security Groups (to allow incoming traffic, etc)


## Example

```
module "eks_node_group" {
  source                      = "../"
  instance_requirements       = {
    memory_mib {
      min = 2048
      max = 32768
    }

    vcpu_count {
      min = 2
      max = 4
    }

    memory_gib_per_vcpu {
      min = 2
      max = 4
    }

    accelerator_count {
      max = 0
    }
  }
  subnet_ids                  = module.vpc.private_subnets
  allowed_security_groups     = ["sg-123456789","sg-987654321"]
  min_size                    = 1
  max_size                    = 2
  stack_name                  = "example"
  kubernetes_version          = "1.23"
  eks_cluster_endpoint        = "https://987654321.gr7.us-east-1.eks.amazonaws.com"
  eks_cluster_auth_token      = "k8s-aws-v1.aHR0cHM6Ly9zdHM....."
  eks_cluster_ca_certificate  = "LS0tLS1CRUdJTiBDRVJUSUZJQ0....."
}
```

## Inputs


stack_name
eks_cluster_endpoint
eks_cluster_auth_token
eks_cluster_ca_certificate
allowed_security_groups
min_size
max_size
subnet_ids
kubernetes_versions

Optional

wait_for_cluster_cmd
wait_for_cluster_interpreter


tags

## Outputs

node_group_arn

# terraform-aws-eks-spot-attribute-workers

Use instance attributes with Spot for EKS workers

This ensures that you've got a wider swath of instances to choose from and that your cluster will remain stable for longer periods of time.

# To Deploy

```
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```



## TODO

Get private endpoint working

Private cluster endpoint
[WARNING]: Worker node outbound IP to internet is 44.198.9.93. It is not allowed in the cluster Public CIDR ranges. Please review this URL for further details: https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html

???
[WARNING]: No secondary private IP addresses are assigned to worker node i-02135051d6f571060, ensure that the CNI plugin is running properly. Please review this URL for further details: https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html

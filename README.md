# terraform-aws-eks-spot-attribute-workers

Use instance attributes and mixed instance policies with Spot for EKS workers

This ensures that you've got a wider swath of instances to choose from and that your cluster will remain stable for longer periods of time.

There's also Session Manager access enabled for the nodes. I use this for troubleshooting bootstrap issues.

# To Deploy

```
terraform init
terraform plan -var="cluster_name=my-cool-spot-cluster" -var="aws_region=us-east-1" -out plan.tfplan 
terraform apply plan.tfplan
```

# To Destroy

```
terraform destroy -var="cluster_name=my-cool-spot-cluster" -var="aws_region=us-east-1"
```


## TODO

Get private endpoint working

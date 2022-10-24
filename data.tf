data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amazon-eks-node-1.23-*",
    ]
  }
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}
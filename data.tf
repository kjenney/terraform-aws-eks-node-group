data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amazon-eks-node-${var.kubernetes_version}-*",
    ]
  }
}

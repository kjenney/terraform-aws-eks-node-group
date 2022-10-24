provider "kubernetes" {
  host                   = aws_eks_cluster.example.endpoint
  token                  = data.aws_eks_cluster_auth.example.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority.0.data)
}

resource "kubernetes_config_map" "iam_nodes_config_map" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data  = {
    mapRoles = <<ROLES
- rolearn: ${aws_iam_role.worker_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
  }

  depends_on = [
    null_resource.wait_for_cluster
  ]
}
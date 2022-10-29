resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command     = var.wait_for_cluster_cmd
    interpreter = var.wait_for_cluster_interpreter
    environment = {
      ENDPOINT = var.eks_cluster_endpoint
    }
  }
}

provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  token                  = var.eks_cluster_auth_token
  cluster_ca_certificate = var.eks_cluster_ca_certificate
}

resource "kubernetes_config_map" "iam_nodes_config_map" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data  = {
    mapRoles = <<ROLES
- rolearn: ${aws_iam_role.eks_node_role.arn}
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
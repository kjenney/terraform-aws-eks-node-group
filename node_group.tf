locals {
  tags = merge(tomap({
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"}),
    var.tags,
  )
}

resource "aws_iam_role" "eks_node_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "eks_node_profile" {
  name = "eks_node_profile"
  role = aws_iam_role.eks_node_role.name
  tags = var.tags
}

resource "aws_iam_role_policy" "session_manager_policy" {
  name = "session_manager_policy"
  role = aws_iam_role.eks_node_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:*",
        "ssmmessages:*",
        "ec2messages:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# using a static path here to account for environments where pulling in external
# modules is not an option
module "eks_node_group" {
  source                              = "../terraform-aws-autoscaling"
  count                               = var.go_turbo ? 1 : 0

  name                                = "instance-req-${var.cluster_name}"
  
  vpc_zone_identifier                 = var.vpc_zone_identifier
  min_size                            = var.min_size
  max_size                            = var.max_size
  desired_capacity                    = try(var.desired_capacity, var.min_size)

  update_default_version              = true
  create_launch_template              = true
  image_id                            = data.aws_ami.amazon_linux.id
  iam_instance_profile_name           = aws_iam_instance_profile.eks_node_profile.name
  health_check_type                   = "EC2"
  security_groups                     = [aws_security_group.node_group_sg.id]
  user_data                           = base64encode(templatefile("${path.module}/user_data.sh.tpl", { cluster_name = var.cluster_name }))

  use_mixed_instances_policy          = var.use_mixed_instances_policy
  mixed_instances_policy              = var.mixed_instances_policy
  instance_requirements               = var.instance_requirements
  
  network_interfaces                  = var.network_interfaces
  autoscaling_group_tags              = var.autoscaling_group_tags
  block_device_mappings               = var.block_device_mappings
  capacity_rebalance                  = var.capacity_rebalance
  capacity_reservation_specification  = var.capacity_reservation_specification
  cpu_options                         = var.cpu_options
  ebs_optimized                       = var.ebs_optimized
  elastic_gpu_specifications          = var.elastic_gpu_specifications
  elastic_inference_accelerator       = var.elastic_inference_accelerator
  enable_monitoring                   = var.enable_monitoring
  enabled_metrics                     = var.enabled_metrics
  enclave_options                     = var.enclave_options
  health_check_grace_period           = var.health_check_grace_period
  hibernation_options                 = var.hibernation_options
  instance_market_options             = var.instance_market_options
  instance_refresh                    = var.instance_refresh
  instance_type                       = var.instance_type
  max_instance_lifetime               = var.max_instance_lifetime
  placement                           = var.placement
  placement_group                     = var.placement_group
  private_dns_name_options            = var.private_dns_name_options
  protect_from_scale_in               = var.protect_from_scale_in
  termination_policies                = var.termination_policies
  wait_for_capacity_timeout           = var.wait_for_capacity_timeout
  warm_pool                           = var.warm_pool

  tags                                = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "this" {
  count           = var.go_turbo ? 0 : 1
  cluster_name    = var.cluster_name
  node_group_name = "instance-req-${var.cluster_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = try(var.desired_capacity, var.min_size)
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_security_group" "node_group_sg" {
  name        = "node_group_sg"
  vpc_id      = var.vpc_id
  description = "Security group for node_group_sg"

  ingress {
    description      = "All from anotehr SG"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}
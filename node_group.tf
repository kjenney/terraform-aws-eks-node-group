resource "aws_iam_role" "worker_role" {
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
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "worker_profile"
  role = "${aws_iam_role.worker_role.name}"
}

resource "aws_iam_role_policy" "session_manager_policy" {
  name = "session_manager_policy"
  role = "${aws_iam_role.worker_role.id}"

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

resource "aws_launch_template" "eks_worker" {
  name_prefix = var.cluster_name
  image_id    = data.aws_ami.amazon_linux.id
  vpc_security_group_ids = [module.node_group_sg.security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_profile.name
  }

  instance_requirements {
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

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", { cluster_name = var.cluster_name }))
}

resource "aws_autoscaling_group" "spot" {
  vpc_zone_identifier = module.vpc.private_subnets
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1
  capacity_rebalance = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity = 0
      spot_allocation_strategy = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_worker.id
      }
    }
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_cluster.example
  ]
}

module "node_group_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.cluster_name}_node_group_sg"
  vpc_id      = module.vpc.vpc_id

  description = "Security group for node_group_sg"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
}

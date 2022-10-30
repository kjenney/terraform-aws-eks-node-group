################################################################################
# Launch template
################################################################################

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(module.eks_node_group[0].aws_launch_template.this[0].id, "")
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(module.eks_node_group[0].aws_launch_template.this[0].arn, "")
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = try(module.eks_node_group[0].aws_launch_template.this[0].name, "")
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(module.eks_node_group[0].aws_launch_template.this[0].latest_version, "")
}

output "launch_template_default_version" {
  description = "The default version of the launch template"
  value       = try(module.eks_node_group[0].aws_launch_template.this[0].default_version, "")
}

################################################################################
# IAM Role / Instance Profile
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.eks_node_role.name, "")
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.eks_node_role.arn, "")
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.eks_node_role.unique_id, "")
}

output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.eks_node_profile[0].arn, "")
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.eks_node_profile[0].id, "")
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.eks_node_profile[0].unique_id, "")
}

################################################################################
# EKS Node Group Specific
################################################################################

output "instance_security_group_id" {
  description = "The security group associated with instances in the node group"
  value       = try(aws_security_group.node_group_sg[0].id, "")
}
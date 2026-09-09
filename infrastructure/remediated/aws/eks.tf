resource "aws_eks_cluster" "banking" {
  name     = "banking-remediated"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.banking.arn
    }
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name      = "banking-remediated"
    DataClass = "financial-workloads"
  }
}
variable "aws_region" {
  description = "AWS region used for static training configuration"
  type        = string
  default     = "eu-west-1"
}

variable "transaction_logs_bucket_name" {
  description = "Fictional transaction log bucket name"
  type        = string
  default     = "fictional-banking-transaction-logs-vulnerable"
}

variable "vpc_id" {
  description = "Fictional VPC identifier used for static analysis"
  type        = string
  default     = "vpc-00000000000000000"
}

variable "database_username" {
  description = "Fictional database administrator username"
  type        = string
  default     = "banking_admin"
}

variable "database_password" {
  description = "Database password supplied securely at runtime"
  type        = string
  sensitive   = true
}

variable "eks_cluster_role_arn" {
  description = "Fictional EKS cluster IAM role ARN"
  type        = string
  default     = "arn:aws:iam::000000000000:role/fictional-eks-cluster-role"
}

variable "eks_subnet_ids" {
  description = "Fictional subnet identifiers used for static analysis"
  type        = list(string)

  default = [
    "subnet-00000000000000001",
    "subnet-00000000000000002"
  ]
}
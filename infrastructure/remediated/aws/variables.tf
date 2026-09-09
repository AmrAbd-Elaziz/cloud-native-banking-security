variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "training-remediated"
}

variable "vpc_id" {
  description = "VPC containing the banking platform"
  type        = string
  default     = "vpc-00000000000000000"
}

variable "vpc_cidr" {
  description = "Approved private VPC address range"
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_ids" {
  description = "Private subnets used by RDS"
  type        = list(string)

  default = [
    "subnet-00000000000000001",
    "subnet-00000000000000002"
  ]
}

variable "eks_subnet_ids" {
  description = "Private subnets used by EKS"
  type        = list(string)

  default = [
    "subnet-00000000000000003",
    "subnet-00000000000000004"
  ]
}

variable "transaction_logs_bucket_name" {
  description = "Primary encrypted transaction-log bucket"
  type        = string
  default     = "fictional-banking-transaction-logs-remediated"
}

variable "s3_access_logs_bucket_name" {
  description = "Existing secured bucket receiving S3 access logs"
  type        = string
  default     = "fictional-banking-central-access-logs"
}

variable "replication_destination_bucket_arn" {
  description = "Existing encrypted cross-region replication bucket ARN"
  type        = string
  default     = "arn:aws:s3:::fictional-banking-replication-destination"
}

variable "security_notifications_topic_arn" {
  description = "Existing SNS topic receiving security events"
  type        = string
  default     = "arn:aws:sns:eu-west-1:000000000000:banking-security-events"
}

variable "database_name" {
  description = "Fictional banking database name"
  type        = string
  default     = "banking"
}

variable "database_username" {
  description = "Database administrator username"
  type        = string
  default     = "banking_admin"
}

variable "database_password" {
  description = "Database password supplied through a secure runtime channel"
  type        = string
  sensitive   = true
}

variable "rds_monitoring_role_arn" {
  description = "Existing least-privilege RDS enhanced-monitoring role ARN"
  type        = string
  default     = "arn:aws:iam::000000000000:role/rds-enhanced-monitoring"
}

variable "eks_cluster_role_arn" {
  description = "Existing least-privilege EKS cluster role ARN"
  type        = string
  default     = "arn:aws:iam::000000000000:role/banking-eks-cluster"
}
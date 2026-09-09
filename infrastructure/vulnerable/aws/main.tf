terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Intentionally vulnerable infrastructure for authorized static analysis only.
# Do not run terraform apply against a real AWS account.

resource "aws_s3_bucket" "transaction_logs" {
  bucket = var.transaction_logs_bucket_name

  tags = {
    Name        = "banking-transaction-logs"
    Environment = "training-vulnerable"
    DataClass   = "financial"
  }
}

resource "aws_s3_bucket_public_access_block" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "transaction_logs" {
  depends_on = [
    aws_s3_bucket_ownership_controls.transaction_logs,
    aws_s3_bucket_public_access_block.transaction_logs
  ]

  bucket = aws_s3_bucket.transaction_logs.id
  acl    = "public-read"
}

resource "aws_s3_bucket_ownership_controls" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_security_group" "banking_database" {
  name        = "banking-database-vulnerable"
  description = "Intentionally vulnerable banking database access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Public MySQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Public SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Unrestricted outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "banking-database-vulnerable"
    Environment = "training-vulnerable"
  }
}

resource "aws_db_instance" "banking" {
  identifier = "banking-database-vulnerable"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type       = "gp2"
  storage_encrypted  = false

  db_name  = "banking"
  username = var.database_username
  password = var.database_password
  port     = 3306

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.banking_database.id]

  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true
  multi_az                = false

  auto_minor_version_upgrade   = false
  iam_database_authentication_enabled = false
  performance_insights_enabled = false

  enabled_cloudwatch_logs_exports = []

  tags = {
    Name        = "banking-database-vulnerable"
    Environment = "training-vulnerable"
    DataClass   = "cardholder-data"
  }
}

resource "aws_iam_policy" "banking_api" {
  name        = "banking-api-vulnerable-policy"
  description = "Intentionally excessive banking API permissions"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "banking_api" {
  name              = "/banking/vulnerable/api"
  retention_in_days = 1

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "security-audit"
  }
}

resource "aws_eks_cluster" "banking" {
  name     = "banking-vulnerable"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api"]

  tags = {
    Name        = "banking-vulnerable"
    Environment = "training-vulnerable"
  }
}
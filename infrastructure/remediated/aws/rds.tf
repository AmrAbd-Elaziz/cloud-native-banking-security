resource "aws_security_group" "banking_database" {
  name        = "banking-database-remediated"
  description = "Restricted access to the fictional banking database"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from approved private VPC workloads"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "banking-database-remediated"
  }
}

resource "aws_db_subnet_group" "banking" {
  name       = "banking-private-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "banking-private-subnets"
  }
}

resource "aws_db_instance" "banking" {
  identifier = "banking-database-remediated"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.small"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.banking.arn

  db_name  = var.database_name
  username = var.database_username
  port     = 3306

  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.banking.arn

  db_subnet_group_name   = aws_db_subnet_group.banking.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.banking_database.id]

  multi_az                    = true
  backup_retention_period     = 35
  backup_window               = "01:00-02:00"
  maintenance_window          = "sun:03:00-sun:04:00"
  deletion_protection         = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "banking-database-final-snapshot"
  copy_tags_to_snapshot       = true
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  iam_database_authentication_enabled = true

  monitoring_interval = 60
  monitoring_role_arn = var.rds_monitoring_role_arn

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.banking.arn
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
  ]

  tags = {
    Name      = "banking-database-remediated"
    DataClass = "cardholder-data"
  }
}
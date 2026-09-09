resource "aws_s3_bucket" "transaction_logs" {
  bucket = var.transaction_logs_bucket_name

  tags = {
    Name      = "banking-transaction-logs"
    DataClass = "financial-audit"
  }
}

resource "aws_s3_bucket_ownership_controls" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.banking.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  target_bucket = var.s3_access_logs_bucket_name
  target_prefix = "transaction-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "transaction_logs" {
  depends_on = [aws_s3_bucket_versioning.transaction_logs]

  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    id     = "financial-audit-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 2555
    }
  }
}

resource "aws_iam_role" "s3_replication" {
  name = "banking-s3-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "s3.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_replication" {
  name = "banking-s3-replication"
  role = aws_iam_role.s3_replication.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadSourceConfiguration"
        Effect = "Allow"

        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.transaction_logs.arn
      },
      {
        Sid    = "ReadSourceVersions"
        Effect = "Allow"

        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]

        Resource = "${aws_s3_bucket.transaction_logs.arn}/*"
      },
      {
        Sid    = "ReplicateToDestination"
        Effect = "Allow"

        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]

        Resource = "${var.replication_destination_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "transaction_logs" {
  depends_on = [aws_s3_bucket_versioning.transaction_logs]

  role   = aws_iam_role.s3_replication.arn
  bucket = aws_s3_bucket.transaction_logs.id

  rule {
    id     = "cross-region-financial-audit"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = var.replication_destination_bucket_arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.banking.arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
}

resource "aws_s3_bucket_notification" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  topic {
    topic_arn = var.security_notifications_topic_arn

    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*"
    ]
  }
}

resource "aws_s3_bucket_policy" "transaction_logs" {
  bucket = aws_s3_bucket.transaction_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.transaction_logs.arn,
          "${aws_s3_bucket.transaction_logs.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
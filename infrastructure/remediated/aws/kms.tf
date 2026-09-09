data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_kms_key" "banking" {
  description             = "Customer-managed key for fictional banking data"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableAccountKeyAdministration"
        Effect = "Allow"

        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = [
          "kms:CancelKeyDeletion",
          "kms:CreateAlias",
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:DisableKey",
          "kms:EnableKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:ListGrants",
          "kms:ListResourceTags",
          "kms:PutKeyPolicy",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
          "kms:RetireGrant",
          "kms:RevokeGrant",
          "kms:ScheduleKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:UpdateAlias",
          "kms:UpdateKeyDescription"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "banking-data-key"
  }
}

resource "aws_kms_alias" "banking" {
  name          = "alias/banking-data"
  target_key_id = aws_kms_key.banking.key_id
}
resource "aws_iam_policy" "banking_api" {
  name        = "banking-api-remediated-policy"
  description = "Least-privilege access for the fictional banking API"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadAndWriteTransactionLogs"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.transaction_logs.arn}/*"
      },
      {
        Sid    = "ListTransactionLogBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.transaction_logs.arn
      },
      {
        Sid    = "WriteApplicationLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.banking_api.arn}:*"
      },
      {
        Sid    = "UseBankingEncryptionKey"
        Effect = "Allow"

        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]

        Resource = aws_kms_key.banking.arn
      }
    ]
  })
}
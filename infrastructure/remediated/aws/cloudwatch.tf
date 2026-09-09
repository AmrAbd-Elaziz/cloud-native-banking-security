resource "aws_cloudwatch_log_group" "banking_api" {
  name              = "/banking/remediated/api"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.banking.arn

  tags = {
    Name      = "banking-api-audit-logs"
    DataClass = "security-audit"
  }
}
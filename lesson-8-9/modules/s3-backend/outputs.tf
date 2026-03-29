# -----------------------------------------------
# Виводи модуля S3 Backend
# -----------------------------------------------

output "bucket_name" {
  description = "Назва створеного S3-бакета"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "bucket_arn" {
  description = "ARN S3-бакета"
  value       = aws_s3_bucket.terraform_state.arn
}

output "bucket_domain_name" {
  description = "Доменне ім'я S3-бакета"
  value       = aws_s3_bucket.terraform_state.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Регіональне доменне ім'я S3-бакета"
  value       = aws_s3_bucket.terraform_state.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN таблиці DynamoDB"
  value       = aws_dynamodb_table.terraform_locks.arn
}
# -----------------------------------------------
# DynamoDB таблиця для блокування стейтів
# Запобігає одночасному запису декількох
# процесів Terraform до одного стейту
# -----------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Платимо лише за використання
  hash_key     = "LockID"          # Обов'язковий ключ для Terraform

  # Атрибут LockID - ключовий для механізму блокування
  attribute {
    name = "LockID"
    type = "S" # String тип
  }

  # Point-in-time recovery для відновлення таблиці
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = var.table_name
    Description = "Terraform state locking table"
  }
}
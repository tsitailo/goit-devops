# -----------------------------------------------
# Налаштування бекенду для збереження стейтів
# ВАЖЛИВО: Перед використанням бекенду потрібно
# спочатку створити S3 та DynamoDB ресурси!
# -----------------------------------------------

terraform {
  backend "s3" {
    bucket         = "your-unique-bucket-name" # Замініть на ваше ім'я бакета
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
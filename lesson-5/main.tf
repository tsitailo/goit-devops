# -----------------------------------------------
# Головний файл для підключення всіх модулів
# -----------------------------------------------

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

  default_tags {
    tags = {
      Project     = "lesson-5"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# -----------------------------------------------
# Модуль S3 та DynamoDB для зберігання стейтів
# -----------------------------------------------
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = var.bucket_name
  table_name  = var.table_name
  aws_region  = var.aws_region
}

# -----------------------------------------------
# Модуль VPC з публічними та приватними підмережами
# -----------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = var.vpc_name
}

# -----------------------------------------------
# Модуль ECR для зберігання Docker-образів
# -----------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  ecr_name     = var.ecr_name
  scan_on_push = var.scan_on_push
}
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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Поточний AWS акаунт (для ECR URL)
data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "lesson-8-9"
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

# -----------------------------------------------
# Модуль EKS — Kubernetes кластер
# -----------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  node_group_name     = var.node_group_name
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_disk_size      = var.node_disk_size
}

# -----------------------------------------------
# Модуль Jenkins — CI сервер в EKS
# -----------------------------------------------
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name      = module.eks.cluster_name
  aws_account_id    = data.aws_caller_identity.current.account_id
  aws_region        = var.aws_region
  admin_user        = var.jenkins_admin_user
  admin_password    = var.jenkins_admin_password
  github_repo_url   = var.github_repo_url
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  depends_on = [module.eks]
}

# -----------------------------------------------
# Модуль Argo CD — GitOps CD в EKS
# -----------------------------------------------
module "argocd" {
  source = "./modules/argo_cd"

  cluster_name        = module.eks.cluster_name
  github_repo_url     = var.github_repo_url
  github_repo_ssh_url = var.github_repo_ssh_url
  github_repo_ssh_key = var.github_ssh_key

  depends_on = [module.eks]
}
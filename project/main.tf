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
      Project     = "project"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# -----------------------------------------------
# EKS data sources для helm та kubernetes провайдерів
# -----------------------------------------------
data "aws_eks_cluster" "this" {
  name       = var.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = var.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
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
# Модуль RDS — база даних (Aurora або RDS instance)
# -----------------------------------------------
module "rds" {
  source = "./modules/rds"

  use_aurora = var.rds_use_aurora
  identifier = var.rds_identifier
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  db_name     = var.rds_db_name
  db_username = var.rds_db_username
  db_password = var.rds_db_password
  db_port     = var.rds_db_port

  multi_az             = var.rds_multi_az
  aurora_replica_count = var.rds_aurora_replica_count

  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  depends_on = [module.vpc]
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
  ecr_name          = var.ecr_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# -----------------------------------------------
# Модуль Argo CD — GitOps CD в EKS
# -----------------------------------------------
module "argocd" {
  source = "./modules/argo_cd"

  github_repo_url     = var.github_repo_url
  github_repo_ssh_url = var.github_repo_ssh_url
  github_repo_ssh_key = var.github_ssh_key
}

# -----------------------------------------------
# Модуль Monitoring — Prometheus + Grafana
# -----------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  namespace                = var.monitoring_namespace
  prometheus_chart_version = var.prometheus_chart_version
  grafana_chart_version    = var.grafana_chart_version
  grafana_admin_password   = var.grafana_admin_password
  prometheus_retention     = var.prometheus_retention
  prometheus_storage_size  = var.prometheus_storage_size
  grafana_storage_size     = var.grafana_storage_size

  depends_on = [module.eks]
}

# -----------------------------------------------
# Модуль External Secrets Operator
# Синхронізує секрети з AWS Secrets Manager у K8s Secrets
# -----------------------------------------------
module "external_secrets" {
  source = "./modules/external_secrets"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  secret_arns       = [module.rds.secret_arn]

  depends_on = [module.rds]
}
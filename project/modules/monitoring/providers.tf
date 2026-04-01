# -----------------------------------------------
# Оголошення провайдерів для модуля Monitoring
# Провайдери helm та kubernetes передаються з кореневого модуля
# -----------------------------------------------

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

# -----------------------------------------------
# Змінні для модуля VPC
# -----------------------------------------------

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "Необхідно вказати коректний CIDR блок."
  }
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.public_subnets) >= 1
    error_message = "Необхідно вказати хоча б одну публічну підмережу."
  }
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  validation {
    condition     = length(var.private_subnets) >= 1
    error_message = "Необхідно вказати хоча б одну приватну підмережу."
  }
}

variable "availability_zones" {
  description = "Список зон доступності для розміщення підмереж"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "Назва VPC"
  type        = string
  default     = "project-vpc"
}

variable "enable_dns_hostnames" {
  description = "Увімкнути DNS імена хостів у VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Увімкнути підтримку DNS у VPC"
  type        = bool
  default     = true
}
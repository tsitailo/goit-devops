# -----------------------------------------------
# Змінні для модуля EKS
# -----------------------------------------------

variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "project-eks"
}

variable "cluster_version" {
  description = "Версія Kubernetes"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID VPC для розміщення кластера"
  type        = string
}

variable "private_subnet_ids" {
  description = "Список ID приватних підмереж для вузлів кластера"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Список ID публічних підмереж (для LoadBalancer)"
  type        = list(string)
}

variable "node_group_name" {
  description = "Назва групи вузлів"
  type        = string
  default     = "project-nodes"
}

variable "node_instance_types" {
  description = "Типи EC2 інстансів для вузлів"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Бажана кількість вузлів"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість вузлів"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Максимальна кількість вузлів"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Розмір диску вузла (ГБ)"
  type        = number
  default     = 20
}

variable "endpoint_private_access" {
  description = "Увімкнути приватний доступ до API сервера"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Увімкнути публічний доступ до API сервера"
  type        = bool
  default     = true
}

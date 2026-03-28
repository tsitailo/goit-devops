# -----------------------------------------------
# Виводи модуля VPC
# -----------------------------------------------

output "vpc_id" {
  description = "ID створеного VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Список CIDR блоків публічних підмереж"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Список CIDR блоків приватних підмереж"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "Список ID NAT Gateway"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Список публічних IP адрес NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "public_route_table_id" {
  description = "ID публічної таблиці маршрутів"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Список ID приватних таблиць маршрутів"
  value       = aws_route_table.private[*].id
}
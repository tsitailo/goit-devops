# -----------------------------------------------
# Налаштування маршрутизації для VPC
# -----------------------------------------------

# ----- Публічна таблиця маршрутів -----
# Одна спільна таблиця для всіх публічних підмереж
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Маршрут для виходу в інтернет через Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
    Type = "public"
  }
}

# Прив'язка публічних підмереж до публічної таблиці маршрутів
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----- Приватні таблиці маршрутів -----
# Окрема таблиця для кожної приватної підмережі
# (кожна використовує свій NAT Gateway)
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  # Маршрут через NAT Gateway для виходу в інтернет
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"
    Type = "private"
  }
}

# Прив'язка приватних підмереж до відповідних таблиць маршрутів
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
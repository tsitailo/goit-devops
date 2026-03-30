# -----------------------------------------------
# Основні мережеві ресурси VPC
# -----------------------------------------------

# Головний VPC ресурс
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = var.vpc_name
  }
}

# -----------------------------------------------
# Internet Gateway для публічних підмереж
# Забезпечує вихід в інтернет для публічних ресурсів
# -----------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# -----------------------------------------------
# Публічні підмережі
# Ресурси в цих підмережах доступні з інтернету
# -----------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  # Автоматично призначати публічну IP адресу
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# -----------------------------------------------
# Приватні підмережі
# Ресурси в цих підмережах НЕ доступні з інтернету напряму
# -----------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  # НЕ призначати публічну IP адресу
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# -----------------------------------------------
# Elastic IP для NAT Gateway
# NAT Gateway потребує статичну публічну IP адресу
# -----------------------------------------------
resource "aws_eip" "nat" {
  count  = length(var.public_subnets)
  domain = "vpc"

  # EIP залежить від Internet Gateway
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  }
}

# -----------------------------------------------
# NAT Gateway для приватних підмереж
# Дозволяє ресурсам у приватних підмережах
# виходити в інтернет (але не навпаки)
# -----------------------------------------------
resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  # NAT Gateway залежить від Internet Gateway
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-nat-gw-${count.index + 1}"
  }
}
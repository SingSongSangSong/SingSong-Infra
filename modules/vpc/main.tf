// VPC 생성
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "singsongsangsong-vpc"
  }
}

// Public Subnet 2개 생성
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_blocks[0]
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "singsong-public-subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_blocks[1]
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "singsong-public-subnet2"
  }
}

// Private Subnet 2개 생성
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "singsong-private-subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "singsong-private-subnet2"
  }
}

// Internet Gateway 생성
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "singsong-igw"
  }
}

// Public Route Table 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

// Public Route Table Association
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

// Private Route Table 생성
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
}

// Private Route Table Association
resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
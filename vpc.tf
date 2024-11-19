# // VPC 생성
# resource "aws_vpc" "singsong_vpc" {
#   cidr_block = var.vpc_cidr_block
#   enable_dns_hostnames = true
#   enable_dns_support = true
#
#   tags = {
#     Name = "singsongsangsong-vpc"
#   }
# }
#
# // Public Subnet 2개 생성
# resource "aws_subnet" "singsong_public_subnet1" {
#   vpc_id     = aws_vpc.singsong_vpc.id
#   cidr_block = var.public_subnet_cidr_blocks[0]
#   availability_zone = "ap-northeast-2a"
#
#   tags = {
#     Name = "singsong-public-subnet1"
#   }
# }
#
# resource "aws_subnet" "singsong_public_subnet2" {
#   vpc_id     = aws_vpc.singsong_vpc.id
#   cidr_block = var.public_subnet_cidr_blocks[1]
#   availability_zone = "ap-northeast-2c"
#
#   tags = {
#     Name = "singsong-public-subnet2"
#   }
# }
#
# // Private Subnet 2개 생성
# resource "aws_subnet" "singsong_private_subnet1" {
#   vpc_id     = aws_vpc.singsong_vpc.id
#   cidr_block = var.private_subnet_cidr_blocks[0]
#   availability_zone = "ap-northeast-2a"
#
#   tags = {
#     Name = "singsong-private-subnet1"
#   }
# }
#
# resource "aws_subnet" "singsong_private_subnet2" {
#   vpc_id     = aws_vpc.singsong_vpc.id
#   cidr_block = var.private_subnet_cidr_blocks[1]
#   availability_zone = "ap-northeast-2c"
#
#   tags = {
#     Name = "singsong-private-subnet2"
#   }
# }
#
# // Internet Gateway 생성
# resource "aws_internet_gateway" "singsong_igw" {
#   vpc_id = aws_vpc.singsong_vpc.id
#
#   tags = {
#     Name = "singsong-igw"
#   }
# }
#
# // Route Table 생성
# resource "aws_route_table" "singsong_public_route_table" {
#   vpc_id = aws_vpc.singsong_vpc.id
#
#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = "local"
#   }
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.singsong_igw.id
#   }
# }
#
# // Route Table Association
# resource "aws_route_table_association" "singsong_public_subnet1_association" {
#   subnet_id      = aws_subnet.singsong_public_subnet1.id
#   route_table_id = aws_route_table.singsong_public_route_table.id
# }
#
# resource "aws_route_table_association" "singsong_public_subnet2_association" {
#   subnet_id      = aws_subnet.singsong_public_subnet2.id
#   route_table_id = aws_route_table.singsong_public_route_table.id
# }
#
# // Private Route Table 생성
# resource "aws_route_table" "singsong_private_route_table" {
#   vpc_id = aws_vpc.singsong_vpc.id
#
#   route {
#     cidr_block  = "10.0.0.0/16"
#     gateway_id  = "local"
#   }
# }
#
# // Private Route Table Association
# resource "aws_route_table_association" "singsong_private_subnet1_association" {
#   subnet_id      = aws_subnet.singsong_private_subnet1.id
#   route_table_id = aws_route_table.singsong_private_route_table.id
# }
#
# resource "aws_route_table_association" "singsong_private_subnet2_association" {
#   subnet_id      = aws_subnet.singsong_private_subnet2.id
#   route_table_id = aws_route_table.singsong_private_route_table.id
# }
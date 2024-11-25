# // RDS 생성
# resource "aws_db_subnet_group" "singsong_db_subnet_group" {
#   subnet_ids = [aws_subnet.singsong_private_subnet1.id, aws_subnet.singsong_private_subnet2.id]
# }
#
# resource "aws_db_instance" "singsong_db" {
#   allocated_storage    = 30
#   storage_type         = "gp3"
#   engine               = "mysql"
#   engine_version       = "8.0.35"
#   multi_az             = true
#   instance_class       = "db.t4g.micro"
#   identifier           = "singsong-identifier"
#   db_name              = var.db_name
#   username             = var.db_username
#   password             = var.db_password
#   db_subnet_group_name = aws_db_subnet_group.singsong_db_subnet_group.name
#   parameter_group_name = "singsong-db-parameter-group"
#   vpc_security_group_ids = [aws_security_group.mysql_sg.id]
#   skip_final_snapshot  = true
#   final_snapshot_identifier = "singsong-db-final-snapshot"
# }
#
# // RDS Parameter Group
# resource "aws_db_parameter_group" "singsong_db_parameter_group" {
#   family      = "mysql8.0"
#   name        = "singsong-db-parameter-group"
#   description = "Custom parameter group for singsong RDS instance"
#
#   parameter {
#     name  = "character_set_server"
#     value = "utf8mb4"
#   }
#
#   parameter {
#     name  = "collation_server"
#     value = "utf8mb4_unicode_ci"
#   }
#
#   parameter {
#     name  = "time_zone"
#     value = "Asia/Seoul"
#   }
# }
#
# resource "aws_ssm_parameter" "db_password" {
#   name  = "/singsong/RDSPassword"
#   type  = "SecureString"
#   value = var.db_password
# }
#
# resource "aws_ssm_parameter" "db_username" {
#   name  = "/singsong/RDSUsername"
#   type  = "String"
#   value = var.db_username
# }
#
# resource "aws_ssm_parameter" "db_endpoint" {
#   name  = "/singsong/RDSEndpoint"
#   type  = "String"
#   value = element(split(":", aws_db_instance.singsong_db.endpoint), 0)
# }
#
# resource "aws_ssm_parameter" "db_name" {
#     name  = "/singsong/RDSName"
#     type  = "String"
#     value = aws_db_instance.singsong_db.db_name
# }
#
# resource "aws_ssm_parameter" "db_identifier" {
#     name  = "/singsong/RDSIdentifier"
#     type  = "String"
#     value = aws_db_instance.singsong_db.identifier
# }
#
# resource "aws_ssm_parameter" "db_port" {
#     name  = "/singsong/RDSPort"
#     type  = "String"
#     value = aws_db_instance.singsong_db.port
# }
#

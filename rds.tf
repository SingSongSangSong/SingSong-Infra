// RDS 생성
resource "aws_db_subnet_group" "singsong_db_subnet_group" {
  subnet_ids = [aws_subnet.singsong_private_subnet1.id, aws_subnet.singsong_private_subnet2.id]
}

resource "aws_db_instance" "singsong_db" {
  allocated_storage    = 30
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0.35"
  multi_az             = true
  instance_class       = "db.t4g.micro"
  identifier           = "singsong-identifier"
  db_name              = "singsongdb"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.singsong_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot  = true
  final_snapshot_identifier = "singsong-db-final-snapshot"
}
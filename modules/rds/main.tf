resource "aws_db_subnet_group" "this" {
  name        = var.subnet_group_name
  description = "Subnet group for RDS"
  subnet_ids  = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  family      = var.db_parameter_family
  name        = var.db_parameter_group_name
  description = "Custom parameter group for RDS instance"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  multi_az               = var.multi_az
  instance_class         = var.instance_class
  identifier             = var.db_identifier
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
}

resource "aws_ssm_parameter" "db_password" {
  name  = var.ssm_password_name
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "db_username" {
  name  = var.ssm_username_name
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = var.ssm_endpoint_name
  type  = "String"
  value = aws_db_instance.this.endpoint
}
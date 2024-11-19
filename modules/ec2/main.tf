// security group for bastion host
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 19530
    to_port   = 19530
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9091
    to_port   = 9091
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9001
    to_port   = 9001
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2379
    to_port   = 2379
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// key pair for bastion host
resource "aws_key_pair" "bastion_key" {
  key_name   = var.ec2_key_name
  public_key = var.ec2_public_key
}


data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_eip" "bastion_eip"{
  instance = aws_instance.this.id
}

// bastion host instance
resource "aws_instance" "this" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "c6g.xlarge"
  key_name      = aws_key_pair.bastion_key.key_name
  subnet_id     = var.public_subnet1_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "./milvus-docker-compose.yml"  # 로컬 파일 경로
    destination = "/home/ec2-user/milvus-docker-compose.yml"  # EC2 내부 경로
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ec2_private_key)  # private key 파일 경로
      host        = aws_instance.this.public_ip
    }
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "bastion-host"
  }
}
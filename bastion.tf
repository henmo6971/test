resource "aws_security_group" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-"
  description = "Bastion host in the Management subnet"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bastion-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.this["management"].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.tester.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "${var.name_prefix}-bastion"
  }

  depends_on = [aws_route_table_association.management]
}

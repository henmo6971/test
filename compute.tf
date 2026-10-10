data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "application" {
  name_prefix = "${var.name_prefix}-application-"
  description = "No external traffic as requested"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from within the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic for package installation and updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-application-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "application" {
  name_prefix   = "${var.name_prefix}-application-"
  image_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.application.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = false
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf install -y httpd
    PRIVATE_IP=$(hostname -I | awk '{print $1}')

    cat > /var/www/html/index.html <<HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Application Server</title>
      </head>
      <body>
        <h1>Amazon Linux 2023</h1>
        <p>Instance private IP: $${PRIVATE_IP}</p>
      </body>
    </html>
    HTML

    systemctl enable --now httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-application"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.name_prefix}-application"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "application" {
  name_prefix        = "${var.name_prefix}-application-"
  min_size           = 2
  max_size           = 6
  desired_capacity   = 2
  vpc_zone_identifier = [aws_subnet.this["application"].id]
  health_check_type  = "EC2"

  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-application"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table_association.private]
}

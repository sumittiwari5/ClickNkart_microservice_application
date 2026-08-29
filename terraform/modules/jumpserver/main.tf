# ============================================================
# UBUNTU 24.04 LTS AMI
# ============================================================

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ============================================================
# JUMP SERVER
# ============================================================

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = var.public_subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile = var.instance_profile_name

  # No public IPv4 / Elastic IP
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash

              set -e

              apt-get update -y
              apt-get upgrade -y

              echo "Ubuntu Jump Server initialized" > /var/log/jumpserver-init.log
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-jumpserver"

    Role = "management"

    Project     = var.project_name
    Environment = var.environment
    OS          = "Ubuntu 24.04 LTS"
  }
}
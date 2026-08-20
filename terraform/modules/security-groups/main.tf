resource "aws_security_group" "jumpserver" {
  name        = "${var.project_name}-${var.environment}-jumpserver-sg"
  description = "Security group for ClickNCart Jump Server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from administrator"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"] #  or we can go with the cidr of the server from where we want to use ansible 
    # so that way it would be more secure, rather than opening ssh for everyone.
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jumpserver-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for ClickNCart RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL access from Jump Server"
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.jumpserver.id]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}
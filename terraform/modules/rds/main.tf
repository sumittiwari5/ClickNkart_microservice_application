# WHY RDS INSTEAD OF MYSQL-IN-A-POD (the change from your local/basic
# setup): a database is STATEFUL - it's not something you want restarted,
# rescheduled, or living on ephemeral pod storage the way your stateless
# Spring Boot pods are. RDS gives you automated backups, Multi-AZ
# failover, and patching without you managing any of that yourself -
# exactly the kind of undifferentiated heavy lifting a real team offloads
# to a managed service instead of reinventing inside Kubernetes.

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids # RDS lives in PRIVATE subnets only - never reachable from the internet directly, see the security-groups module
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  storage_type          = "gp3"
  storage_encrypted     = true # encryption at rest - non-negotiable for anything holding user data (emails, hashed passwords)

  db_subnet_group_name  = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  username = var.db_username
  password = var.db_password

  # MICROSERVICE NOTE: unlike the local docker-compose setup where init.sql
  # auto-creates userdb/catalogdb/orderdb on first boot, RDS doesn't run
  # init scripts. You create the 3 databases once, manually or via the
  # provided script, after this resource is created - see
  # docs/PHASE_3_RDS.md for the exact commands.

  multi_az                = false # set true for real production - runs a synchronous standby in a second AZ for automatic failover, roughly doubles RDS cost
  backup_retention_period  = 7    # automated daily backups, kept 7 days - this is what "Amazon RDS Automated Backups" in your spec refers to
  backup_window            = "03:00-04:00"
  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.project_name}-mysql-final-snapshot"
  deletion_protection      = true # requires an explicit extra step to ever delete this - a deliberate safety brake against `terraform destroy` run against the wrong workspace

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
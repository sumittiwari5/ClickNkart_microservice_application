aws_region  = "us-east-1"
project_name = "clickncart"
environment  = "dev"

key_name = "YOUR_EXISTING_KEYPAIR_NAME"

admin_ip_cidr = "YOUR.PUBLIC.IP.ADDRESS/32" # run the command "curl -s ifconfig.me" on your ubuntu machine

# ============================================================
# RDS
# ============================================================

rds_engine_version = "8.0"

rds_instance_class = "db.t3.micro"

rds_allocated_storage     = 20
rds_max_allocated_storage = 30

rds_db_name = "clickncart"

rds_db_username = "admin"

rds_backup_retention_period = 7

rds_skip_final_snapshot = true

rds_deletion_protection = false
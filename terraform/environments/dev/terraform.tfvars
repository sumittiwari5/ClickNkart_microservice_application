# Copy this to terraform.tfvars (which is gitignored) and fill in real values.
# NEVER commit terraform.tfvars itself.

<<<<<<< HEAD
aws_region    = "ap-south-1"
admin_ip_cidr = "YOUR.IP.HERE/32"
=======
aws_region = "ap-south-1"
admin_ip_cidr = "your-ip-here/32"
>>>>>>> f963095784f6adbb972f8fcfeb21f2873d6e0776

# db_password is intentionally NOT here - set it via:
#   export TF_VAR_db_password="your-strong-password"
# so it never touches disk in plaintext at all.
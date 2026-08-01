# Copy this to terraform.tfvars (which is gitignored) and fill in real values.
# NEVER commit terraform.tfvars itself.

aws_region    = "ap-south-1"
admin_ip_cidr = "YOUR.IP.HERE/32"

jenkins_key_name = "clickncart-key"   # whatever you named it when you imported it

# db_password is intentionally NOT here - set it via:
#   export TF_VAR_db_password="your-strong-password"
# so it never touches disk in plaintext at all.
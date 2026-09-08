# After the creation of Infra, database, and running the Ansible playbook. 
we can not run the pipeline direct before it we need to run few file and create few thing manually to let then exist before running the pipeline (or the creation of the pipeline).

# 1. Kubernetes :
rds database password: Mysqlrdspass005

cluster_name = "clickncart-dev-eks"
jumpserver_instance_id = "i-072b32471c9a85357"
jumpserver_private_ip = "10.0.1.69"
jumpserver_security_group_id = "sg-00cc4ed35e000970c"
private_subnet_ids = [
  "subnet-0e7a15c4b6c772ed4",
  "subnet-088be00c7fb1a8ad4",
]
public_subnet_ids = [
  "subnet-0f566f0da34bb6211",
  "subnet-0b3bddec57481f43b",
]
rds_endpoint = "clickncart-dev-mysql.cwjasuacoezf.us-east-1.rds.amazonaws.com"
rds_endpoint_with_port = "clickncart-dev-mysql.cwjasuacoezf.us-east-1.rds.amazonaws.com:3306"
rds_port = 3306
rds_security_group_id = "sg-077cd9c56f31defac"
vpc_id = "vpc-06047956a9eb89483"


# commands from here : 

kubectl create secret generic rds-secret \
  -n clickncart \
  --from-literal=MYSQL_HOST='clickncart-dev-mysql.cwjasuacoezf.us-east-1.rds.amazonaws.com' \
  --from-literal=MYSQL_USERNAME='admin' \
  --from-literal=MYSQL_PASSWORD='Mysqlrdspass005'
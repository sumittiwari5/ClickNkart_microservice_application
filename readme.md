# After the creation of the Infrastructure and running Ansible playbook.

#1. now check on the jumpserver 
aws sts get-caller-identity

#2. then after that again on the jumpserver 
aws eks describe-cluster \
  --region us-east-1 \
  --name clickncart-dev-eks

#3. after that, on the jumpserver, configure the kubeconfig 
aws eks update-kubeconfig \
  --region us-east-1 \
  --name clickncart-dev-eks

# should see like 
# Added new context arn:aws:eks:us-east-1:000606610451:cluster/clickncart-dev-eks to /home/ubuntu/.kube/config

#4. after that once check the current cotext 
kubectl config current-context

# should see something like this 
arn:aws:eks:us-east-1:000606610451:cluster/clickncart-dev-eks

#5. check the kubectl working 
kubectl get nodes

#6. after it on the jumpserver branch pull the main branch of the deployment, where we have the  init.sql file.
# we need to run the init.sql file on the RDS to create the database and to put the prerequisite items in the database.
# for such run the command :
 mysql -h clickncart-dev-mysql.cwjasuacoezf.us-east-1.rds.amazonaws.com -u admin -p < ~/ClickNkart_microservice_application/database/init.sql
 




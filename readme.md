# now check on the jumpserver 
aws sts get-caller-identity

# then after that again on the jumpserver 
aws eks describe-cluster \
  --region us-east-1 \
  --name clickncart-dev-eks

# after that, on the jumpserver, configure the kubeconfig 
aws eks update-kubeconfig \
  --region us-east-1 \
  --name clickncart-dev-eks

# should see like 
# Added new context arn:aws:eks:us-east-1:000606610451:cluster/clickncart-dev-eks to /home/ubuntu/.kube/config

# after that once check the current cotext 
kubectl config current-context

# should see something like this 
arn:aws:eks:us-east-1:000606610451:cluster/clickncart-dev-eks




# ---------------- OIDC Provider - required for IRSA ----------------
# IRSA (IAM Roles for Service Accounts) is how a specific POD gets its own
# narrow AWS permissions, instead of every pod on a node inheriting the
# whole node's IAM role (which would be a much bigger blast radius if any
# one pod were compromised). This requires the EKS cluster's OIDC issuer
# to be registered as an IAM identity provider - that's what this
# resource does. The AWS Load Balancer Controller and Cluster Autoscaler,
# set up later, both need this.

resource "aws_iam_openid_connect_provider" "eks" {

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  url = var.eks_oidc_issuer_url
}

data "tls_certificate" "eks" {
  url = var.eks_oidc_issuer_url
}
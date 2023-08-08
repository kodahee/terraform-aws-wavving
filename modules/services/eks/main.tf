locals {
  cluster_policy = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
  
  # oidc                = trimprefix("${aws_eks_cluster.cluster-prod.identity[0].oidc[0].issuer}", "https://")
  # oidc                = trimprefix("${aws_eks_cluster.cluster-dev.identity[0].oidc[0].issuer}", "https://")
  yaml_crd_path       = "${path.module}/yaml/sencondry_cidr/CustomResourceDefinition.yaml"
  yaml_eni_path       = "${path.module}/yaml/sencondry_cidr/ENIconfig.yaml"
  yaml_sa_path        = "${path.module}/yaml/sencondry_cidr/ServiceAccount.yaml"
  yaml_cert_mgmt_path = "${path.module}/yaml/ingress/cert-manager.yaml"
  yaml_ingress_path   = "${path.module}/yaml/ingress/IngressController.yaml"
}

// 1. EKS Cluster 생성
// 1-1. role 연동
// 1-2. public access는 제한
// 1-3. subnet은 sbn_pri 사용
// 1-4. security group은 cluster 사용
// 2. eks role 생성 후 eks cluster/service policy 연동

// 1-1. EKS 클러스터에 접근하기 위한 Role 생성
resource "aws_iam_role" "cluster" {
  name = "iam-${var.prefix}-role-eks"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    Name    = "iam-${var.prefix}-role-eks",
    Service = "role-eks"
  }
}

// 1-2. EKS 클러스터를 위한 Role과 정책 연결
resource "aws_iam_role_policy_attachment" "cluster" {
  for_each   = toset(local.cluster_policy)
  policy_arn = each.key
  role       = aws_iam_role.cluster.name
}

################

// 1. eks cluster 용 security_group 
resource "aws_security_group" "eks_cluster" {
  name   = "sg_${var.prefix}-ekscluster" // sg의 naming rule에 맨앞 '-'가 허용 안되서 '_'사용
  vpc_id = var.vpc_id

  egress { // all port
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // tcp만 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // tcp만 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "sg_${var.prefix}-ekscluster",
    Service = "ekscluster"
  }
}

// EKS Cluster 생성
resource "aws_eks_cluster" "cluster-prod" {
  name     = "eks-${var.env[0]}-${var.prefix}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.23"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster
  ]

  tags = {
    Name    = "eks-${var.env[0]}-${var.prefix}-cluster",
    Service = "cluster"
  }
}

resource "aws_eks_cluster" "cluster-dev" {
  name     = "eks-${var.env[1]}-${var.prefix}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.23"

  vpc_config { // eks에 private access 로 제한함
    endpoint_private_access = true
    endpoint_public_access  = true

    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster
  ]

  tags = {
    Name    = "eks-${var.env[1]}-${var.prefix}-cluster",
    Service = "cluster"
  }
}

##################

data "aws_caller_identity" "current" {}

// OIDC Provider용 CA-thumbprint data 생성
data "tls_certificate" "cluster-tls-prod" {
  url = aws_eks_cluster.cluster-prod.identity[0].oidc[0].issuer
}
// OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "eks_oidc_provider-prod" {
  url = aws_eks_cluster.cluster-prod.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["${data.tls_certificate.cluster-tls-prod.certificates.0.sha1_fingerprint}"]
}

// OIDC Provider용 CA-thumbprint data 생성
data "tls_certificate" "cluster-tls-dev" {
  url = aws_eks_cluster.cluster-dev.identity[0].oidc[0].issuer
}
// OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "eks_oidc_provider-dev" {
  url = aws_eks_cluster.cluster-dev.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["${data.tls_certificate.cluster-tls-dev.certificates.0.sha1_fingerprint}"]
}

// EKS Cluster 정보 확인
data "aws_eks_cluster" "eks_cluster-prod" {
  name = aws_eks_cluster.cluster-prod.name
}

data "aws_eks_cluster_auth" "eks_cluster-prod" {
  depends_on = [aws_eks_cluster.cluster-prod]
  name       = aws_eks_cluster.cluster-prod.name
}

data "aws_eks_cluster" "eks_cluster-dev" {
  name = aws_eks_cluster.cluster-dev.name
}

data "aws_eks_cluster_auth" "eks_cluster-dev" {
  depends_on = [aws_eks_cluster.cluster-prod]
  name       = aws_eks_cluster.cluster-dev.name
}

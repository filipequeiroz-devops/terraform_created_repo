data "tls_certificate" "eks" {
  url = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_cluster" "my_eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.eks_security_group.id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "my_eks_node_group" {

  depends_on = [aws_iam_role.eks_cluster_role, aws_iam_role.eks_node_role]

  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "my-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    "subnet-0bfaee34eb5d44756",
    "subnet-053ba0e0ff85f0645"
  ] #minha subnet id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

resource "aws_security_group" "eks_security_group" {
  name        = "my-eks-security-group"
  description = "Security group for EKS cluster"
  vpc_id      = "vpc-0568d4cf1350f0b7a"

  dynamic "ingress" {
    for_each = var.security_groups_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_access_entry" "admins" {
  for_each      = var.eks_admins
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

# 2. Concede permissão total de leitura/escrita no cluster para este usuário
resource "aws_eks_access_policy_association" "console_user_admin" {
  for_each      = var.eks_admins
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admins[each.key].principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.my_eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer
}
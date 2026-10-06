#Testing the creation of a Kubernetes IAM user with Terraform wich will be able to just list pods

resource "aws_iam_user" "kubernetes_user" {
  name = "kubernetes-user"
}

resource "aws_iam_user_policy_attachment" "kubernetes_user_policy" {
  user       = aws_iam_user.kubernetes_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

## 2. Registra o Usuário no EKS e associa ao grupo "pod-viewers" (sem policy da AWS)
#resource "aws_eks_access_entry" "k8s_user_entry" {
#  cluster_name      = "meu-cluster-eks"
#  principal_arn     = aws_iam_user.kubernetes_user.arn
#  kubernetes_groups = ["pod-viewers"]
#  type              = "STANDARD"
#}
#
## 3. Cria a regra granular dentro do Kubernetes (Apenas Pods)
#resource "kubernetes_cluster_role" "pod_reader" {
#  metadata {
#    name = "pod-reader"
#  }
#
#  rule {
#    api_groups = [""]
#    resources  = ["pods"]
#    verbs      = ["get", "list"]
#  }
#}
#
## 4. Conecta o grupo "pod-viewers" à regra criada
#resource "kubernetes_cluster_role_binding" "pod_reader_binding" {
#  metadata {
#    name = "pod-reader-binding"
#  }
#
#  subject {
#    kind      = "Group"
#    name      = "pod-viewers"
#    api_group = "rbac.authorization.k8s.io"
#  }
#
#  role_ref {
#    api_group = "rbac.authorization.k8s.io"
#    kind      = "ClusterRole"
#    name      = kubernetes_cluster_role.pod_reader.metadata[0].name
#  }
#}
#
#output "kubernetes_user_arn" {
#  value = aws_iam_user.kubernetes_user.arn
#}
#
#output "kubernetes_user_id" {
#  value = aws_iam_user.kubernetes_user.id
#}
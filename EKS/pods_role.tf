data "aws_secretsmanager_secret" "meu_secret" {
  name = "databa-access"
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      # Você precisa substituir com o seu Account ID, Região e o ID do cluster OIDC
      identifiers = ["arn:aws:iam::<SEU_ACCOUNT_ID>:oidc-provider/oidc.eks.<REGIAO>.amazonaws.com/id/<ID_DO_SEU_OIDC>"]
    }

    condition {
      test = "StringEquals"
      # Ajuste também o OIDC URL aqui e o namespace, caso não esteja no "default"
      variable = "oidc.eks.<REGIAO>.amazonaws.com/id/<ID_DO_SEU_OIDC>:sub"
      values   = ["system:serviceaccount:default:secrets-sa"]
    }
  }
}

resource "aws_iam_policy" "secret_policy" {
  name = "SecretsManagerPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = data.aws_secretsmanager_secret.meu_secret.arn
    }]
  })
}

resource "aws_iam_role" "secret_role" {
  name = "eks-secret-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.secret_role.name
  policy_arn = aws_iam_policy.secret_policy.arn
}
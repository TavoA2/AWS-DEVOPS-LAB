resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:TavoA2@OWNER_ID/AWS-DEVOPS-LAB@REPO_ID:pull_request",
              "repo:TavoA2@OWNER_ID/AWS-DEVOPS-LAB@REPO_ID:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Project   = "aws-devops-lab"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "administrator" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
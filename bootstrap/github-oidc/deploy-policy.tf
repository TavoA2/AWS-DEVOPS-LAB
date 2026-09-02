resource "aws_iam_policy" "github_actions_deploy" {
  name        = "github-actions-deploy-policy"
  description = "Least privilege policy for GitHub Actions deployments"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "TerraformStateBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::tavoa2-aws-devops-lab-tfstate"
      },

      {
        Sid    = "TerraformStateObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = [
          "arn:aws:s3:::tavoa2-aws-devops-lab-tfstate/environments/dev/terraform.tfstate",
          "arn:aws:s3:::tavoa2-aws-devops-lab-tfstate/environments/dev/terraform.tfstate.tflock"
        ]
      },

      {
        Sid    = "EC2Read"
        Effect = "Allow"

        Action = [
          "ec2:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "AutoScalingRead"
        Effect = "Allow"

        Action = [
          "autoscaling:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "ELBRead"
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "IAMRead"
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:GetInstanceProfile",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]

        Resource = "*"
      },

      {
        Sid    = "CloudWatchRead"
        Effect = "Allow"

        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListTagsForResource"
        ]

        Resource = "*"
      },

      {
        Sid    = "LogsRead"
        Effect = "Allow"

        Action = [
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource"
        ]

        Resource = "*"
      },

      {
        Sid    = "ECRRead"
        Effect = "Allow"

        Action = [
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]

        Resource = "*"
      },

      {
        Sid    = "LaunchTemplateDeployment"
        Effect = "Allow"

        Action = [
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate"
        ]

        Resource = "*"
      },

      {
        Sid    = "AutoScalingDeployment"
        Effect = "Allow"

        Action = [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:StartInstanceRefresh",
          "autoscaling:CancelInstanceRefresh"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "ec2:RunInstances",
          "ec2:CreateTags"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = "arn:aws:iam::200015573044:role/dev-ec2-ssm-role"

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
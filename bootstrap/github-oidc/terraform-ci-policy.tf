resource "aws_iam_policy" "github_actions_terraform" {
  name        = "github-actions-terraform-policy"
  description = "Least-privilege policy for GitHub Actions Terraform CI"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "TerraformStateAccess"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]

        Resource = [
          "arn:aws:s3:::tavoa2-aws-devops-lab-tfstate",
          "arn:aws:s3:::tavoa2-aws-devops-lab-tfstate/*"
        ]
      },

      {
        Sid    = "EC2ReadAccess"
        Effect = "Allow"

        Action = [
          "ec2:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "ElasticLoadBalancingReadAccess"
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "AutoScalingReadAccess"
        Effect = "Allow"

        Action = [
          "autoscaling:Describe*"
        ]

        Resource = "*"
      },

      {
        Sid    = "IAMReadAccess"
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListPolicyVersions"
        ]

        Resource = "*"
      },

      {
        Sid    = "CloudWatchReadAccess"
        Effect = "Allow"

        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]

        Resource = "*"
      },

      {
        Sid    = "CloudWatchLogsReadAccess"
        Effect = "Allow"

        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Project   = "aws-devops-lab"
    ManagedBy = "terraform"
  }
}
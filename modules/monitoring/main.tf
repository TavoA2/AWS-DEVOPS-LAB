resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-ec2-high-cpu"
  alarm_description   = "Triggers when EC2 CPU utilization is high"

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"

  period              = 300
  evaluation_periods  = 1

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold

  dimensions = {
    InstanceId = var.instance_id
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_cloudwatch_metric_alarm" "application_unhealthy" {
  alarm_name        = "${var.environment}-application-unhealthy"
  alarm_description = "Triggers when the application health check fails"

  namespace   = "AWSDevOpsLab"
  metric_name = "ApplicationHealth"
  statistic   = "Minimum"

  period             = 60
  evaluation_periods = 1

  comparison_operator = "LessThanThreshold"
  threshold           = 1

  dimensions = {
    InstanceId = var.instance_id
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

# ============================================================
# CloudWatch Logs - Nginx
# ============================================================
resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/aws/ec2/${var.environment}/nginx/access"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Project     = "aws-devops-lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/aws/ec2/${var.environment}/nginx/error"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Project     = "aws-devops-lab"
    ManagedBy   = "terraform"
  }
}
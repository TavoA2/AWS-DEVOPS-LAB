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
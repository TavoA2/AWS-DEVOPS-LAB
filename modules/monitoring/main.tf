resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name        = "${var.environment}-ec2-high-cpu"
  alarm_description = "Triggers when EC2 CPU utilization is high"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 1

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

# ============================================================
# ALB / Target Group Monitoring
# ============================================================

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name        = "${var.environment}-alb-unhealthy-targets"
  alarm_description = "Triggers when the ALB target group has unhealthy targets"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Average"

  period             = 60
  evaluation_periods = 2

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name        = "${var.environment}-alb-target-5xx"
  alarm_description = "Triggers when ALB targets return HTTP 5XX errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"

  period             = 60
  evaluation_periods = 2

  comparison_operator = "GreaterThanThreshold"
  threshold           = 5

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name        = "${var.environment}-alb-5xx"
  alarm_description = "Triggers when the Application Load Balancer generates HTTP 5XX errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  period             = 60
  evaluation_periods = 2

  comparison_operator = "GreaterThanThreshold"
  threshold           = 5

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name        = "${var.environment}-alb-high-response-time"
  alarm_description = "Triggers when target response time is high"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"
  statistic   = "Average"

  period             = 60
  evaluation_periods = 3

  comparison_operator = "GreaterThanThreshold"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "notBreaching"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

# ============================================================
# SRE - Availability SLI / SLO
# ============================================================

resource "aws_cloudwatch_metric_alarm" "availability_slo" {
  alarm_name        = "${var.environment}-availability-slo"
  alarm_description = "Triggers when service availability falls below the 99.9% SLO"

  comparison_operator = "LessThanThreshold"
  threshold           = 99.9

  evaluation_periods  = 5
  datapoints_to_alarm = 2

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "availability"
    expression  = "IF(requests>0,((requests-FILL(target_errors,0)-FILL(elb_errors,0))/requests)*100,100)"
    label       = "AvailabilityPercent"
    return_data = true
  }

  metric_query {
    id = "requests"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }

    return_data = false
  }

  metric_query {
    id = "target_errors"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
        TargetGroup  = var.target_group_arn_suffix
      }
    }

    return_data = false
  }

  metric_query {
    id = "elb_errors"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }

    return_data = false
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

# ============================================================
# SRE - Error Budget Burn Rate
# ============================================================

resource "aws_cloudwatch_metric_alarm" "error_budget_fast_burn" {
  alarm_name        = "${var.environment}-error-budget-fast-burn"
  alarm_description = "Triggers when the 99.9% SLO error budget is burning faster than 10x"

  comparison_operator = "GreaterThanThreshold"
  threshold           = 10

  evaluation_periods  = 5
  datapoints_to_alarm = 2

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "burn_rate"
    expression  = "IF(requests>0,((FILL(target_errors,0)+FILL(elb_errors,0))/requests)/0.001,0)"
    label       = "ErrorBudgetBurnRate"
    return_data = true
  }

  metric_query {
    id = "requests"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }

    return_data = false
  }

  metric_query {
    id = "target_errors"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
        TargetGroup  = var.target_group_arn_suffix
      }
    }

    return_data = false
  }

  metric_query {
    id = "elb_errors"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      period      = 60
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }

    return_data = false
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}
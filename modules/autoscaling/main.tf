resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type

network_interfaces {
  associate_public_ip_address = true
  security_groups             = [var.security_group_id]
  device_index                = 0
}

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(file(var.user_data_path))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-asg-web"
      Environment = var.environment
      Project     = "aws-devops-lab"
      ManagedBy   = "terraform"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.environment}-web-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 3

  default_cooldown = 180

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "aws-devops-lab"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.environment}-web-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
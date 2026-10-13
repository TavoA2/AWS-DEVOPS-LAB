moved {
  from = module.networking.aws_eip.nat
  to   = module.networking.aws_eip.nat[0]
}

moved {
  from = module.networking.aws_nat_gateway.main
  to   = module.networking.aws_nat_gateway.main[0]
}

moved {
  from = module.networking.aws_route.private_internet
  to   = module.networking.aws_route.private_internet[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.ecr_api
  to   = module.networking.aws_vpc_endpoint.ecr_api[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.ecr_dkr
  to   = module.networking.aws_vpc_endpoint.ecr_dkr[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.ssm
  to   = module.networking.aws_vpc_endpoint.ssm[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.ssmmessages
  to   = module.networking.aws_vpc_endpoint.ssmmessages[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.ec2messages
  to   = module.networking.aws_vpc_endpoint.ec2messages[0]
}

moved {
  from = module.networking.aws_vpc_endpoint.logs
  to   = module.networking.aws_vpc_endpoint.logs[0]
}

moved {
  from = module.autoscaling.aws_autoscaling_policy.cpu_target_tracking
  to   = module.autoscaling.aws_autoscaling_policy.cpu_target_tracking[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.unhealthy_targets
  to   = module.monitoring.aws_cloudwatch_metric_alarm.unhealthy_targets[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.target_5xx
  to   = module.monitoring.aws_cloudwatch_metric_alarm.target_5xx[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.alb_5xx
  to   = module.monitoring.aws_cloudwatch_metric_alarm.alb_5xx[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.high_response_time
  to   = module.monitoring.aws_cloudwatch_metric_alarm.high_response_time[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.availability_slo
  to   = module.monitoring.aws_cloudwatch_metric_alarm.availability_slo[0]
}

moved {
  from = module.monitoring.aws_cloudwatch_metric_alarm.error_budget_fast_burn
  to   = module.monitoring.aws_cloudwatch_metric_alarm.error_budget_fast_burn[0]
}

moved {
  from = module.loadbalancing.aws_lb.main
  to   = module.loadbalancing.aws_lb.main[0]
}

moved {
  from = module.loadbalancing.aws_lb_listener.http
  to   = module.loadbalancing.aws_lb_listener.http[0]
}

moved {
  from = module.loadbalancing.aws_lb_target_group.web
  to   = module.loadbalancing.aws_lb_target_group.web[0]
}

moved {
  from = module.loadbalancing.aws_security_group.alb
  to   = module.loadbalancing.aws_security_group.alb[0]
}

moved {
  from = module.loadbalancing.aws_vpc_security_group_egress_rule.alb_to_web
  to   = module.loadbalancing.aws_vpc_security_group_egress_rule.alb_to_web[0]
}

moved {
  from = module.loadbalancing.aws_vpc_security_group_ingress_rule.alb_http
  to   = module.loadbalancing.aws_vpc_security_group_ingress_rule.alb_http[0]
}

moved {
  from = module.loadbalancing.aws_vpc_security_group_ingress_rule.alb_https
  to   = module.loadbalancing.aws_vpc_security_group_ingress_rule.alb_https[0]
}

moved {
  from = module.loadbalancing.aws_vpc_security_group_ingress_rule.web_from_alb
  to   = module.loadbalancing.aws_vpc_security_group_ingress_rule.web_from_alb[0]
}
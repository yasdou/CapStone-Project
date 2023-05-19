resource "aws_autoscaling_group" "ASJellyfin" {
  name = "JellyfinAutoScalingGroup"
  min_size             = var.asg_min
  max_size             = var.asg_max
  desired_capacity     = var.asg_desired
  launch_template {
    id = aws_launch_template.launchtemplate.id
  }
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  target_group_arns    = [aws_alb_target_group.TGJellyfin.arn]

   depends_on = [
     aws_s3_object.JellyfinFiles,
   ]
}

# scale up alarm
resource "aws_autoscaling_policy" "cpu-policyscaleup" {
  name = "cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.ASJellyfin.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.up_scaling_adjustment
  cooldown = var.up_cooldown
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaleup" {
  alarm_name = "cpu-alarm"
  alarm_description = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.up_threshold
  dimensions = {
  "AutoScalingGroupName" = "${aws_autoscaling_group.ASJellyfin.name}"
  }
  actions_enabled = var.actions_enabled_up
  alarm_actions = ["${aws_autoscaling_policy.cpu-policyscaleup.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
  name = "example-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.ASJellyfin.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.down_scaling_adjustment
  cooldown = var.down_cooldown
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
  alarm_name = "cpu-alarm-scaledown"
  alarm_description = "cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.up_threshold
  dimensions = {
  "AutoScalingGroupName" = "${aws_autoscaling_group.ASJellyfin.name}"
  }
  actions_enabled = var.actions_enabled_up
  alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}

# Launch Template Resource
resource "aws_launch_template" "launchtemplate" {
  name_prefix = "JellyfinServer"
  image_id = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SGServer.id]
  key_name = var.ami_key_pair_name
  iam_instance_profile {
    name = var.instance_profile
  }
  user_data = base64encode(templatefile("${path.module}/scripts/start-JF.sh", local.vars))
  monitoring {
    enabled = true
  }
  depends_on = [
      aws_security_group.JellyfinELBSG
   ]
}

#notifications for whenver autoscaling group scales up or down

resource "aws_autoscaling_notification" "jellyfin_notifications" {
  group_names = [
    aws_autoscaling_group.ASJellyfin.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.SNSJellyfin.arn
}

resource "aws_sns_topic" "SNSJellyfin" {
  name = "SNSJellyfin"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.SNSJellyfin.arn
  protocol  = "email"
  endpoint  = var.useremail
}
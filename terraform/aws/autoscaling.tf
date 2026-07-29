resource "aws_autoscaling_group" "jenkins" {

  name = "${local.project_prefix}-jenkins-asg"

  desired_capacity = 1

  min_size = 1

  max_size = 2

  vpc_zone_identifier = [
    aws_subnet.private["private_a"].id,
    aws_subnet.private["private_b"].id
  ]

  target_group_arns = [
    aws_lb_target_group.jenkins.arn
  ]

  health_check_type = "ELB"

  health_check_grace_period = 1200

  launch_template {
    id      = aws_launch_template.jenkins.id
    version = aws_launch_template.jenkins.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${local.project_prefix}-jenkins"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "Jenkins"
    propagate_at_launch = true
  }

}
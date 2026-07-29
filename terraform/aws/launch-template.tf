resource "aws_launch_template" "jenkins" {

  name = "${local.project_prefix}-jenkins-lt"

  image_id = var.jenkins_ami_id

  instance_type = var.jenkins_instance_type

  key_name = aws_key_pair.main.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  user_data = base64encode(
    file("${path.module}/userdata/jenkins.sh")
  )

  monitoring {
    enabled = true
  }

  block_device_mappings {

    device_name = "/dev/sda1"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }

  }

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "${local.project_prefix}-jenkins"
      Role = "Jenkins"
    }

  }

}
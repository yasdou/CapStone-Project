# Launch Template Resource
resource "aws_launch_template" "launchtemplate" {
  name = "WPlaunchtemplate"
  image_id = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SG_ecs_tasks.id]
  key_name = var.ami_key_pair_name
  iam_instance_profile {
    name = "LabInstanceProfile"
  }
  user_data = base64encode(templatefile("${path.module}/start-JF.sh", local.vars))
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Wordpresslaunchtemplate"
    }
  }
}
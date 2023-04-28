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
#  user_data = base64encode(templatefile("${path.module}/bash-init.sh", local.vars))
  user_data            = base64encode("#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config")
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
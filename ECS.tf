##################
### Repository ###
##################

resource "aws_ecr_repository" "main" {
  name                 = "${var.name}-repository"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "keep last 10 images"
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}

##################
###### ECS #######
##################

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                = "jellyfin"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([{
   name        = "${var.name}-container"
   image       = "${var.container_image}:latest"
   essential   = true
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   }])
}

resource "aws_ecs_service" "main" {
 name                               = "${var.name}-service"
 cluster                            = aws_ecs_cluster.main.id
 task_definition                    = aws_ecs_task_definition.main.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 
#  network_configuration {
#    security_groups  = [aws_security_group.SG_ecs_tasks.id]
#    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
#    assign_public_ip = true
#  }
 
#  load_balancer {
#    target_group_arn = "${aws_alb_target_group.WPTG.arn}"
#    container_name   = "${var.name}-container"
#    container_port   = var.container_port
#  }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}
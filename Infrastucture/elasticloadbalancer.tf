resource "aws_alb" "ELBJellyfin" {
  name               = "ELBJellyfin"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.JellyfinELBSG.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_alb_target_group" "TGJellyfin" {
  name     = "TGJellyfin"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.JellyfinVPC.id
  
  lifecycle { create_before_destroy=true }

  health_check {
    path = "/healthcheck.html"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 404 or fails
  }

}

resource "aws_alb_listener" "Jellylistener" {
  load_balancer_arn = "${aws_alb.ELBJellyfin.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.TGJellyfin.arn
   }
}
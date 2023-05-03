resource "aws_alb" "ELBJellyfin" {
  name               = "ELBJellyfin"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.WordpressELBSG.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_alb_target_group" "TGJellyfin" {
  name     = "TGJellyfin"
  port     = 80
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
    matcher = "404"  # has to be HTTP 404 or fails
  }

}

#create ALB listener for WP Servers
resource "aws_alb_listener" "WPlistener" {
  load_balancer_arn = "${aws_alb.ELBJellyfin.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = var.container_port
      status_code = "HTTP_301"
    }
   }
}
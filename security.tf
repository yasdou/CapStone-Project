//security.tf
resource "aws_security_group" "WordpressELBSG" {
    
    vpc_id = "${aws_vpc.WPvpc.id}"
    
    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }


    // Terraform removes the default rule
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
    Name = "WordpressELBSG"
    } 
}

resource "aws_security_group" "SG_ecs_tasks" {
  name   = "${var.name}-sg-task"
  vpc_id = "${aws_vpc.WPvpc.id}"
 
  ingress {
   protocol         = "tcp"
   from_port        = var.container_port
   to_port          = var.container_port
   #change CIDR Range to ELB SG
   cidr_blocks      = ["0.0.0.0/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ec2_aurora" {
  name        = "allow_ec2_aurora"
  description = "Allow EC2 to Aurora traffic"
  vpc_id      = aws_vpc.WPvpc.id

  ingress {
    description      = "allow bastion to aurora"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_aurora_access" {
  name        = "allow_aurora_access"
  description = "Allow EC2 to aurora"
  vpc_id = aws_vpc.WPvpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  tags = {
    Name = "aurora-stack-allow-aurora-MySQL"
  }
}
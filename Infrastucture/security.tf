//security.tf
resource "aws_security_group" "JellyfinELBSG" {
    name   = "${var.name}-sg-ELB"
    vpc_id = "${aws_vpc.JellyfinVPC.id}"
    
    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "HTTP"
    from_port        = 8096
    to_port          = 8096
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

resource "aws_security_group" "SGServer" {
    name   = "${var.name}-sg-Server"
    vpc_id = "${aws_vpc.JellyfinVPC.id}"
    
    ingress {
    description      = "HTTP"
    from_port        = 8096
    to_port          = 8096
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
    Name = "${var.name}-sg-Server"
    } 
}

resource "aws_security_group" "allow_ec2_aurora" {
  name        = "allow_ec2_aurora"
  description = "Allow EC2 to Aurora traffic"
  vpc_id      = aws_vpc.JellyfinVPC.id

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
  vpc_id = aws_vpc.JellyfinVPC.id

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


resource "aws_security_group" "ec2-sec-grp" {
  name = "${local.tag}-instance-sg"
  description = "Allow SSH, HTTP and MySQL inbound traffic"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb-sec-grp.id]
  }  

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb-sec-grp" {
  name = "${local.tag}-alb-sg"
  description = "Allow HTTP inbound traffic"

  ingress{
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds-sec-grp" {
  name = "${local.tag}-rds-sg"
  description = "Allow MySQL inbound traffic"

  ingress{
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = [aws_security_group.ec2-sec-grp.id]
    }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
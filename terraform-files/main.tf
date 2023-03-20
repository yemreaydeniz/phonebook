locals {
  ec2_instance-type = "t2.micro"
  rds-instance-type = "db.t2.micro"
  key-name = "first-key"
  tag = "phone-book"
}

resource "aws_launch_template" "my-launch-temp" {
  name = "${local.tag}-launch-template"

  image_id = data.aws_ami.amazon-linux-2.id

  instance_type = local.ec2_instance-type

  key_name = local.key-name

  vpc_security_group_ids = [aws_security_group.ec2-sec-grp.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.tag}-instance"
    }
  }
  user_data = filebase64("${path.module}/user-data.sh")
}

resource "aws_lb" "my-alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sec-grp.id]
  subnets = [for s in data.aws_subnet.subnet_value: s.id]

}

resource "aws_lb_target_group" "my-turgut" {
  name     = "my-turgut"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.MyVpc
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    path = "/"
    matcher = "200"
    timeout = 2
    interval = 15
  }
}

resource "aws_lb_listener" "my-listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-turgut.arn
  }
}

resource "aws_autoscaling_group" "my-asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns = [aws_lb_target_group.my-turgut.arn ]
  launch_template {
    id      = aws_launch_template.my-launch-temp.id
    version = "$Latest"
  }
}

resource "aws_db_instance" "my-db" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = local.rds-instance-type
  username             = "admin"
  password             = "admin12345"
  identifier = "database-1"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds-sec-grp.id]
}
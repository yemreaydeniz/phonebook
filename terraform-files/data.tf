data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

variable "MyVpc" {
  default = "vpc-033ab2eeb012575b1"
}

data "aws_subnet" "subnet_value" {
  for_each = toset(data.aws_subnets.subnet.ids)
  id       = each.value
}

data "aws_subnets" "subnet" {
  filter {
    name = "vpc-id"
    values = [var.MyVpc]
  }
}
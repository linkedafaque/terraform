// Terraform does not support user-defined functions, so only
// functions defined by terraform can be used. 
// https://www.terraform.io/docs/language/functions/lookup.html

locals {
  time = formatdate("DD MMM YYYY hh:mm:ZZZ", timestamp())
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "tags" {
  type    = list(any)
  default = ["firstec2", "secondec2"]
}

variable "ami" {
  type = map(any)
  default = {
    "us-east-1"  = "ami-0e999cbd62129e3b1"
    "us-west-2"  = "ami-0e999cbd62129e3b1"
    "ap-south-1" = "ami-0e999cbd62129e3b1"
  }
}

resource "aws_key_pair" "loginkey" {
  key_name   = "login-key"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_instance" "app-dev" {
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.loginkey.key_name
  count         = 2
  tags = {
    Name = element(var.tags, count.index)
  }
}

output "timestamp" {
  value = local.time
}

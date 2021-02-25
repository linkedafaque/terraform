locals {
  common_tags = {
    Owner   = "DevOps Team"
    service = "backend"
  }
}

resource "aws_instance" "dev-instance-0" {
  ami           = "ami-0e999cbd62129e3b1"
  instance_type = "t2.micro"
  tags          = local.common_tags
}

resource "aws_instance" "prod-instance-0" {
  ami           = "ami-0e999cbd62129e3b1"
  instance_type = "t2.large"
  tags          = local.common_tags
}
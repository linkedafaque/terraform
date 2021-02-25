locals {
  common_tags = {
      Owner = "DevOps Team"
      service = "backend"
  }
}

resource "aws_instance" "dev" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = "t2.micro"
  tags = locals.common_tags
}

resource "aws_instance" "prod" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = "t2.large"
  tags = locals.common_tags
}
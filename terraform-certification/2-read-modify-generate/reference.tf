// Declaration method 1
resource "aws_instance" "web" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = var.instance_type
}

// Declaration method 2
// resource "aws_instance" "web" {
//   ami = "ami-0e999cbd62129e3b1"
//   instance_type = var.types["us-west-2"]
// }

// Declaration method 3
// resource "aws_instance" "web" {
//   ami = "ami-0e999cbd62129e3b1"
//   instance_type = var.list[1]
// }

resource "aws_eip" "lb" {
  vpc      = true
}

// 1. Reference an IP address to an instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.lb.id
}

// 2. Reference an IP address to a SG
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.lb.public_ip}/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }
}

// Create a new load balancer
resource "aws_elb" "myelb" {
  name               = var.elb_name
  availability_zones = var.az

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = var.timeout
  connection_draining         = true
  connection_draining_timeout = var.timeout
}


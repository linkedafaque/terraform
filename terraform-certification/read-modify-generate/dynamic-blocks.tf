variable "sg-ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201, 8300, 9200, 9500]
}

resource "aws_security_group" "dynamic-sg" {
  name        = "dynamic-sg"
  description = "ingress for vault"

  // If iterator = port is not specified, then
  // dynamic block name can be used. For e.g.
  // from_port = ingress.value
  dynamic "ingress" {
    for_each = var.sg-ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.sg-ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
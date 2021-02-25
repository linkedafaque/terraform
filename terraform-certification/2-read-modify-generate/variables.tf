variable "vpn_ip" {
  default = "116.50.30.20/32"
}

variable "instance_type" {
  default = "t2.micro"
}

// The value of this variable is defined within
// the .tfvars file
// variable "instance_type" {}

variable "user_id" {
  type = number
}

variable "elb_name" {
  type = string
}

variable "az" {
  type = list(any)
}

variable "timeout" {
  type = number
}

variable "types" {
  type = map(any)
  default = {
    us-east-1  = "t2.micro"
    us-west-2  = "t2.nano"
    ap-south-1 = "t2.small"
  }
}

variable "list" {
  type    = list(any)
  default = ["m5.large", "m5.xlarge", "t2.medium"]
}

variable "elb_names" {
  type    = list(any)
  default = ["prod-loadbalancer", "dev-loadbalancer", "stage-loadbalancer"]
}
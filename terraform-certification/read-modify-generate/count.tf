// Using the count parameter to create 2 instances 
resource "aws_instance" "instance" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = "t2.micro"
  count = 2
}

// In order to solve the problem of all having same
// names, we use count.index But loadbalancer0, 
// loadbalancer1 may not be suitable names. Instead 
// we may need prod-loadbalancer, dev-loadbalancer.
// resource "aws_iam_user" "lb" {
//   name = "loadbalancer.${count.index}"
//   path = "/system/"
//   count = 3
// }

// This will resolve the problem of 0,1, 2 and 
// assign proper names to the loadbalancer. 
resource "aws_iam_user" "lb" {
  name = var.elb_names[count.index]
  path = "/system/"
  count = 3
}

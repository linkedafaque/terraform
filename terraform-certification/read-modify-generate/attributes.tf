resource "aws_instance" "web" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = "t2.micro"
}

resource "aws_eip" "lb" {
  vpc      = true
}

// Print out only public ip address
output "eip-ip" {
  value = aws_eip.lb.public_ip
}

// Print all values associated with eip
output "eip" {
  value = aws_eip.lb
}

resource "aws_s3_bucket" "terraform-demo-bucket" {
  bucket = "terraform-demo-205"
}

// Print out only bucket name
output "terraform-demo-bucket-domain-name" {
  value = aws_s3_bucket.terraform-demo-bucket.bucket_domain_name
}

// Print all values associated with the s3 bucket
output "terraform-demo-bucket" {
  value = aws_s3_bucket.terraform-demo-bucket
}
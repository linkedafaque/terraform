provider "aws" {
  region = "us-east-1"
  access_key = "YOUR-ACCESS-KEY"
  secret_key = "YOUR-SECRET-KEY"
}

################################################
################### TUTORIAL ###################
################################################

// --> Commands
// terraform init: to install and init the providers.
// terraform plan: see the changes going to be applied.
// terraform apply: apply the changes.
// terraform destroy: destroy all declared resources.
// terraform state <list/show>: do operations on various 
//   resources list or show the resource.
// terraform refresh: run a refresh (connects to aws 
//   instances without actually deploying) and just 
//   gets the output or gets the current state and 
//   refreshes the state file (.tfstate)
// terraform destroy -target <resource-type.local-resource-name> 
//   : to delete only to a single resource.
// terraform apply -target <resource-name>: to delete.
// terraform apply -var-file <filename>: to pickup 
//   a particular variable file.
// terraform plan -var="instance_type=t2.small": takes the
//   variable instance_type "t2.small" from the cli.
// terraform expects to use only  `terraform.tfvars` file
//   for defining variable values. If the file has another
//   name, then it needs to be specified in the cli as:
//   terraform plan -var-file="custom.tfvars"  
// terraform fmt: formats the terraform files correctly.
// terraform validate: checks whether the configuration
//   is syntactically valid.
// terraform taint aws_instance.myec2: marks a resource
//  tainted and when terraform plan. The command only
//  updates the state file which is picked by by the
//  plan command that it will be destroyed and a new
//  one will be created.
// terraform graph?
// terraform plan -out=path: saves the plan to a file.
// terraform apply path: a saved plan can be applied.
// terraform output output-variable-name: prints the
//  output of the output variable.
// use terraform plan -refresh=false -target=name
//  to avoid larger api calls as refresh would call
//  aws apis to get the current state

// We tell terraform, how our end-state infrastructure is 
// going to look like, so running the script again doesn't
// create a new EC2 instance, so that the actual state in
// AWS matches what we've done in terraform.

// resource "aws_instance" "first-sever-afaque" {
//   ami           = "ami-02fe94dee086c0c37"
//   instance_type = "t2.micro"
//   tags = {
//     Name = "ubuntu"
//   }
// }

// resource "aws_vpc" "first-vpc-afaque" {
//   cidr_block = "10.0.0.0/16"
//   tags = {
//     Name = "prod-vpc"
//   }
// }

// resource "aws_subnet" "first-subnet-afaque" {
//   vpc_id     = aws_vpc.first-vpc-afaque.id
//   cidr_block = "10.0.1.0/24"

//   tags = {
//     Name = "prod-subnet"
//   }
// }

################################################
################### PROJECT ####################
################################################

// 1. Create VPC.
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "prod-vpc"
  }
}

// 2. Create Internet Gateway.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

// 3. Create Custom Route Table.
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  //// We want all the traffic to go through this gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-route-table"
  }
}

variable "subnet-prefix" {
  description = "cidr block for the subnet"
  type = string
}

variable "dev-prefix" {
  description = "cidr block for the dev subnet"
}

// 4. Create A Subnet
resource "aws_subnet" "prod-subnet" {
  vpc_id = aws_vpc.prod-vpc.id
  // cidr_block = "10.0.1.0/24"
  cidr_block = var.subnet-prefix
  availability_zone = "us-east-1a"
  tags = {
    Name = "prod-subnet"
  }
}

// EXAMPLE
resource "aws_subnet" "dev-subnet" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = var.dev-prefix.cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = var.dev-prefix.name
  }
}

// 5. Associate Subnet With Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

// 6. Create Security Group To Allow Port 22, 80, 443
resource "aws_security_group" "allow-web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-web"
  }
}

// 7. Create A Network Interface With An IP In The Subnet (Created In Step 4)
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]
}

// 8. Assign An Elastic IP To The NIC Created In Step 7
resource "aws_eip" "one" {
  vpc               = true
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

// 9. Create An Ubuntu Server
resource "aws_instance" "web-server-instance" {
  ami = "ami-02fe94dee086c0c37"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"
  
  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
    //!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'  
    EOF

    tags = {
        Name = "web-server"
    }
}

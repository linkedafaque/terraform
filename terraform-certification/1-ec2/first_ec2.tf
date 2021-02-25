provider "aws" {
  region = "us-west-2"
  access_key = "YOUR-ACCESS-KEY"
  secret_key = "YOUR-SECRET-KEY"
}

resource "aws_instance" "web" {
  ami = "ami-0e999cbd62129e3b1"
  instance_type = "t2.micro"
}

// This is required for the newer versions of terraform (>0.13.0)
// and is mainly used for non-hashicorp maintained providers. For
// hashicorp maintained providers, the old method of only using
// providers will also work fine.
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.5.1"
    }
  }
}
provider "digitalocean" {}

// State File: Terraform stores the state of the infrastructure
// being created in the state files. This allows terraform to map
// real world resource to our existing configuration.


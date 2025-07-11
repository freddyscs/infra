terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "remote" {
    organization = "freddyscs"

    workspaces {
      name = "freddyscs"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

resource "aws_instance" "mail_server" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-018901167754cf17a"
  vpc_security_group_ids      = ["sg-08d414baa0f4b20dd"]
  associate_public_ip_address = true
  key_name                    = "wiz-fr-key"

  tags = {
    Name = "MailServer"
  }
}

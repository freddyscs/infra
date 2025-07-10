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

resource "aws_instance" "fr_ec2_ubuntu_tf" {
  ami                    = "ami-09e13cea2cf508a84"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-018901167754cf17a"
  vpc_security_group_ids = [aws_security_group.wiz_fr_public_sg.id]
  associate_public_ip_address = true
  key_name               = "wiz-fr-key"

  tags = {
    Name = "wiz_fr_ec2_ubuntu_18.04_mongo_4.4_tf"
  }
}

// Security Group for Public Subnet
resource "aws_security_group" "wiz_fr_public_sg" {
  name        = "wiz_fr_public_sg"
  description = "Allow SSH, HTTP, HTTPS, and private subnet access"
  vpc_id      = "vpc-068f6d161b2b8eea0" //update vpc_id

  // Public access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow private subnet to talk to public subnet
  ingress {
    description = "Allow from private subnet"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/24"]
  }

  // Allow outbound internet access
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fr_sg"
  }
}
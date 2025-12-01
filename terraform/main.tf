terraform {
  backend "s3" {
    bucket         = "vasu-terraform-state-bucket"      # change to your bucket name
    key            = "ec2-docker-lab/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "vasu-state-lock"             # change to your DynamoDB table
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --------- Network lookups ---------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --------- Security Group ---------

resource "aws_security_group" "web_sg" {
  name        = "terraform-ec2-docker-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

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
}

# --------- EC2 Instance ---------

resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # recreate instance when user_data changes
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              # deploy_version = ${var.deploy_version}

              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              docker pull ${var.docker_image}
              docker run -d --name webapp -p 80:80 ${var.docker_image}
              EOF

  tags = {
    Name = "terraform-ec2-docker-lab"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-0f58b397bc5c1f2e8"
}

variable "docker_image" {
  type = string
}

variable "deploy_version" {
  type    = string
  default = "v1"
}

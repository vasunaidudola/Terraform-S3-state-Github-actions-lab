output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.web_server.id
}

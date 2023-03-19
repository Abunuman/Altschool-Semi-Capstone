output "ec2_public_ip" {
  value = aws_instance.Weavenet-server.public_ip
}
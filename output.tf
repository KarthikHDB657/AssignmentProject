output "instance_ips" {
  value = aws_instance.jenkins.public_ip
}
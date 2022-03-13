terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_instance" "jenkins"{
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "default-ec2"
  provisioner "remote-exec" {
    inline = [
      
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update -qq",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository ppa:deadsnakes/ppa -y",
      "sudo apt install -y python",
      "sudo apt install -y openjdk-11-jdk",
      "sudo apt install jenkins -y",
      "JAVA_HOME=/usr/lib/jvm/openjdk-11",
      "PATH=$PATH:$JAVA_HOME/bin",
      "export PATH",
      "sudo systemctl start jenkins",
      
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.aws_key_pair)
  }

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}

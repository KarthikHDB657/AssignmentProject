variable "aws_key_pair" {
  default = "C:/Users/Karthik/Desktop/devops-master-class-master/devops-master-class-master/aws/aws_keys/default-ec2.pem"
}

variable "ingressrules" {
 type    = list(number)
 default = [22, 8080]
}
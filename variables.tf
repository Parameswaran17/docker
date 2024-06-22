variable "region" {
  description = "AWS region to deploy the resources"
  default     = "eu-west-2"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-09627c82937ccdd6d"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  default     = "/home/paramesh/.ssh/id_rsa.pub"  # Replace with the path to your public key file
}

variable "private_key_path" {
  description = "Path to your SSH private key"
  default     = "/home/paramesh/.ssh/id_rsa"  # Replace with the path to your private key file
}



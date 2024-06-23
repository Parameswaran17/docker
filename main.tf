terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.55.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Define the key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

#Security Group
resource "aws_security_group" "docker_sg" {
  name_prefix = "docker-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP range for better security
  }
   
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance to run Docker
resource "aws_instance" "docker" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              sleep 30

              # Ensure you upload the docker_image.tar file to this path beforehand
              sudo docker pull parameswaran17/docker:latest # Replace 'mydockerimage' with your Docker image
              sudo docker run -d --name mycontainer parameswaran17/docker:latest 
              EOF
    
  provisioner "file" {
    source      = "/home/paramesh/Terraform-Docker-AWS/docker_image.tar"
    destination = "/home/ubuntu/parameswaran17"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "sleep 30",
      "sudo docker load -i /home/ubuntu/parameswaran17/docker.tar",
      "sudo docker stop mycontainer || true",  # Stop the container if it exists
      "sudo docker rm mycontainer || true",    # Remove the container if it exists
      "sudo docker run -d --name mycontainer parameswaran17/docker:latest"    
    
    ]
     

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "docker-instance"
  }
}

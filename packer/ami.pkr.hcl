packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

source "amazon-ebs" "banco_x" {
  ami_name      = "banco_x-base-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name        = "bancox-base"
    Project     = "banco-x"
    ManagedBy   = "packer"
    Environment = "base"
  }
}

build {
  name    = "banco_x-ami"
  sources = ["source.amazon-ebs.banco_x"]

  provisioner "shell" {
    inline = [
      # Atualiza o sistema
      "sudo yum update -y",

      # Instala o Docker
      "sudo amazon-linux-extras install docker -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      # Instala o agente ECS
      "sudo amazon-linux-extras install ecs -y",
      "sudo systemctl enable ecs",

      # SSM Agent já vem na Amazon Linux 2, garante que está ativo
      "sudo systemctl enable amazon-ssm-agent",
      "sudo systemctl start amazon-ssm-agent",

      # Instala o AWS CLI v2
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "rm -rf awscliv2.zip aws/",

      # Valida instalações
      "docker --version",
      "aws --version"
    ]
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

locals {
  public_subnets = [aws_subnet.web_A.id, aws_subnet.web_B.id, aws_subnet.web_C.id]
}


resource "aws_vpc" "a4l_vpc" {
  cidr_block           = "10.16.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true


  tags = {
    Name = "a4l_vpc"
  }
}

resource "aws_internet_gateway" "a4l_igw" {
  vpc_id = aws_vpc.a4l_vpc.id

  tags = {
    Name = "a4l_igw"
  }
}

resource "aws_subnet" "web_A" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "web_A"
  }
}

resource "aws_route_table" "web_RT" {
  vpc_id = aws_vpc.a4l_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a4l_igw.id
  }

  tags = {
    Name = "web_RT"
  }
}


resource "aws_route_table_association" "web_RT_association" {
  count          = length(local.public_subnets)
  subnet_id      = local.public_subnets[count.index]
  route_table_id = aws_route_table.web_RT.id
}

resource "aws_subnet" "app_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.16.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "app_A"
  }

}

resource "aws_subnet" "db_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db_A"
  }

}

resource "aws_subnet" "reserved_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.48.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "reserved_A"
  }

}


resource "aws_subnet" "web_B" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.64.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "web_B"
  }
}

resource "aws_subnet" "app_B" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "app_B"
  }

}

resource "aws_subnet" "db_B" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.96.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db_B"
  }

}

resource "aws_subnet" "reserved_B" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.112.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "reserved_B"
  }

}

resource "aws_subnet" "web_C" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.128.0/20"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "web_C"
  }
}

resource "aws_subnet" "app_C" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.144.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "app_C"
  }

}

resource "aws_subnet" "db_C" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.160.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "db_C"
  }

}

resource "aws_subnet" "reserved_C" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.176.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "reserved_C"
  }

}

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP to web server"
  vpc_id      = aws_vpc.a4l_vpc.id

  ingress {
    description = "HTTP ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH ingress"
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

resource "aws_instance" "docker_vm" {
  ami                         = "ami-0e001c9271cf7f3b9"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.web_A.id
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  key_name = "jenkins-master"

  user_data = <<EOF
  #!/bin/bash
  
  sudo -i
  apt update -y
  apt install nginx -y
  
  
  # install docker
  apt-get install ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  EOF

  tags = {
    Name = "docker_vm"
  }
}
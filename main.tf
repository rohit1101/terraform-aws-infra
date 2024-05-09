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

resource "aws_subnet" "app_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.16.0/20"
  availability_zone = "us-east-1a"
  #   map_public_ip_on_launch = true

  tags = {
    Name = "app_A"
  }

}

resource "aws_subnet" "db_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = "us-east-1a"
  #   map_public_ip_on_launch = true

  tags = {
    Name = "db_A"
  }

}

resource "aws_subnet" "reserved_A" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.48.0/20"
  availability_zone = "us-east-1a"
  #   map_public_ip_on_launch = true

  tags = {
    Name = "reserved_A"
  }

}

resource "aws_route_table" "web_A_RT" {
  vpc_id = aws_vpc.a4l_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a4l_igw.id
  }

  tags = {
    Name = "web_A_RT"
  }
}

resource "aws_route_table_association" "web_A_RT_association" {
  subnet_id      = aws_subnet.web_A.id
  route_table_id = aws_route_table.web_A_RT.id
  #   route_table_id = aws_route_table.bar.id
}

# resource "aws_subnet" "web_B" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.64.0/20"
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "web_B"
#   }
# }

# resource "aws_subnet" "app_B" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.80.0/20"
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "app_B"
#   }

# }

# resource "aws_subnet" "db_B" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.96.0/20"
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "db_B"
#   }

# }

# resource "aws_subnet" "reserved_B" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.112.0/20"
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "reserved_B"
#   }

# }

# resource "aws_subnet" "web_C" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.128.0/20"
#   availability_zone       = "us-east-1c"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "web_C"
#   }
# }

# resource "aws_subnet" "app_C" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.144.0/20"
#   availability_zone       = "us-east-1c"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "app_C"
#   }

# }

# resource "aws_subnet" "db_C" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.160.0/20"
#   availability_zone       = "us-east-1c"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "db_C"
#   }

# }

# resource "aws_subnet" "reserved_C" {
#   vpc_id                  = aws_vpc.a4l_vpc
#   cidr_block              = "10.16.176.0/20"
#   availability_zone       = "us-east-1c"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "reserved_C"
#   }

# }


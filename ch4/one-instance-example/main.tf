provider "aws" {
  region = "us-east-2"
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  min_size = 1
  max_size = 2
  tag {
    key = "Name"
    value = "terrafrom-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-0fb653ca2d3203ac1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id              = aws_subnet.amine-subnet.id
  key_name               = "YOURKEY"

  user_data = <<-EOF
              #!/bin/bash
              cd ~
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-testing-amine"
  }

  

}

resource "aws_security_group" "instance" {
  name = "terraform-testing-sg"
  vpc_id = aws_vpc.amine-test-vpc.id
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = ["YOURPUBLICIP/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "amine-subnet" {
  cidr_block = "10.0.10.0/24"
  vpc_id = aws_vpc.amine-test-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "Amine testing public subnet"
  }
}

resource "aws_vpc" "amine-test-vpc" {   cidr_block = "10.0.0.0/16" }

resource "aws_internet_gateway" "amine-test-gw" {
  vpc_id = aws_vpc.amine-test-vpc.id
  tags = {
    Name = "Amine internet GW"
  }
}

resource "aws_route_table" "rt-amine-test-subnet" {
  vpc_id = aws_vpc.amine-test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amine-test-gw.id
  }
}

resource "aws_route_table_association" "rt-subnet-association" {
  subnet_id = aws_subnet.amine-subnet.id
  route_table_id = aws_route_table.rt-amine-test-subnet.id
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the example instance"
}


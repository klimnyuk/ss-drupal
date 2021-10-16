provider "aws" {
region = "eu-central-1"
}

resource "aws_instance" "my_ubuntu" {
ami = "ami-05f7491af5eef733a"
instance_type = "t2.micro"
key_name = "test"
vpc_security_group_ids = [aws_security_group.my_webserver.id]
user_data = file("docker-install.sh")
tags = {
  Name = "Web Server"
}
provisioner "local-exec" {
  command = "echo ${self.public_ip} > public_ip"
}
}

resource "aws_security_group" "my_webserver" {
  name = "my_webserver_SG"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

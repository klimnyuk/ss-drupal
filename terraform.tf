provider "aws" {
region = "eu-central-1"
}

resource "aws_instance" "my_ubuntu" {
ami = "ami-05f7491af5eef733a"
instance_type = "t2.micro"
key_name = "test"
vpc_security_group_ids = [aws_security_group.my_webserver.id]
user_data = <<EOF
#!/bin/bash
wget -q \
https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.4.9-1_amd64.deb \
https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_20.10.9~3-0~ubuntu-focal_amd64.deb \
https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_20.10.9~3-0~ubuntu-focal_amd64.deb
dpkg -i *.deb
usermod -aG docker ubuntu
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOF

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

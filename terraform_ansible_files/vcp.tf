# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = "${var.vpc-cidr}"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true 

  tags      = {
    Name    = "VPC"
  }
}

# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.vpc.id 

  tags      = {
    Name    = "Internet Gateway"
  }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet-1-cidr}"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-1.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               =  "${var.private-subnet-1-cidr}"
  availability_zone        = "ap-south-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "Private Subnet"
  }
}


resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from the internet"
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

  tags = {
    Name = "security_group"
  }
}





resource "aws_instance" "ansible" {

  ami                    = "ami-079b5e5b3971bd10d"
  instance_type          = "t2.micro"
  key_name               = "jenkins"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = aws_subnet.public-subnet-1.id

  tags = {
     Name = "Ansible"
  }

  connection {
      host        = aws_instance.ansible.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./jenkins.pem")
    }
    provisioner "file" {
    source      = "ansible_terraform.pem"
    destination = "/home/ec2-user/jenkins.pem"
    connection {
      host        = aws_instance.ansible.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./jenkins.pem")
      }
    }

    provisioner "local-exec" {
    command = "echo ${aws_instance.ansible.public_dns} > inventory"
  }

 /*

    provisioner "file" {
    source      = "provisioner.sh"
    destination = "/home/ec2-user/provisioner.sh"
    connection {
    host        = aws_instance.ansible.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./jenkins.pem")
    }
    }
    #provisioner "remote-exec" {
     # inline = ["bash provisioner.sh '${aws_instance.ansible.public_ip}' '${aws_instance.Node1.public_ip}'"]
      #connection {
      #host        = aws_instance.ansible.public_ip
      #type        = "ssh"
      #user        = "ec2-user"
      #private_key = file("./ansible_terraform.pem")
    #}
    #}

    #provisioner "file" {
    #source      = "install-k8s.yml"
    #destination = "/home/ec2-user/install-k8s.yml"
    #connection {
    #host        = aws_instance.ansible.public_ip
    #type        = "ssh"
    #user        = "ec2-user"
    #private_key = file("./ansible_terraform.pem")
    #}

  #}
    #provisioner "remote-exec" {
   # inline = ["ansible-playbook install-k8s.yml"]
    #}
    #provisioner "remote-exec" {
    #command = " ansible-playbook -i '${aws_instance.ansible.public_ip}' install-k8s.yml"
#}  */
}


output "fetched_info_from_aws" {
  value = aws_instance.ansible.public_ip

}
 
/*
resource "aws_instance" "Node1" {

  ami                    = "ami-08f3712c8ca5af75e"
  instance_type          = "t2.micro"
  key_name               = "ansible_terraform"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = aws_subnet.public-subnet-1.id
  tags = {
     Name = "Node1"
  }
  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl set-hostname node" ]
    connection {
      host        = aws_instance.Node1.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./jenkins.pem")
    }
  }
    provisioner "local-exec" {
    command = "echo -e ${aws_instance.Node1.public_dns} > inventory"
  }

}


output "fetched_info_from_aws_for_instance2" {
  value = aws_instance.Node1.public_ip

}
*/


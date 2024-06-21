# Linx VPC
resource "aws_vpc" "Linx-VPC" {
    cidr_block = var.VPC_CIDR
    tags = {
        Name = "Linx-VPC"
    }
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

}
# Linx Public Subnets
resource "aws_subnet" "Linx-Public-SN" {
    vpc_id = aws_vpc.Linx-VPC.id
    cidr_block = var.public_SN_cidr[count.index]
    count = length(var.public_SN_cidr)
    availability_zone = var.availability_zone[count.index]

    tags = {
        Name = var.Public_SN_Tags[count.index]
    }

}

# Linx Private Subnets
resource "aws_subnet" "Linx-Private-SN" {
    vpc_id = aws_vpc.Linx-VPC.id
    cidr_block = var.Private_SN_cidr[count.index]
    count = length(var.Private_SN_cidr)
    availability_zone = var.availability_zone[count.index]

    tags = {
        Name = var.Private_SN_Tags[count.index]

    }

}

resource "aws_internet_gateway" "Linx-IGW" {
    vpc_id = aws_vpc.Linx-VPC.id

    tags = {
        Name = "Linx-IGW"
    }
}
  
resource "aws_route_table" "Linx-RT" {
    vpc_id = aws_vpc.Linx-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Linx-IGW.id
    }

    tags = {
        Name = "Linx-Public-RT"
    }
}

resource "aws_route_table_association" "Linx-RT-Association" {
    count = length(var.public_SN_cidr)
    subnet_id = aws_subnet.Linx-Public-SN[count.index].id
    route_table_id = aws_route_table.Linx-RT.id
}

resource "aws_eip" "NAT-EIP" {
  domain = "vpc"
  count = length(var.public_SN_cidr)
  depends_on = [aws_internet_gateway.Linx-IGW]

  tags = {
    "Name" = "NAT-EIP"
  }
  
}

resource "aws_nat_gateway" "Linx-NAT-GW" {
  allocation_id = aws_eip.NAT-EIP[count.index].id
  count = 2
  subnet_id     = aws_subnet.Linx-Public-SN[count.index].id
  depends_on    = [aws_internet_gateway.Linx-IGW]

  tags = {
    "Name" = "Linx-NAT-GW"
  }
  
}

resource "aws_route_table" "Linx-Private-RT" {
    vpc_id = aws_vpc.Linx-VPC.id
    count = length(var.Private_SN_cidr)
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.Linx-NAT-GW[count.index].id
    }

    tags = {
        Name = "Linx-Private-RT"
    }
}

resource "aws_route_table_association" "Linx-Private-RT-Association" {
    count = length(var.Private_SN_cidr)
    subnet_id = aws_subnet.Linx-Private-SN[count.index].id
    route_table_id = aws_route_table.Linx-Private-RT[count.index].id
}
resource "aws_instance" "Linx-NginX" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = "Test-MGW-Key"
    vpc_security_group_ids = [aws_security_group.Linx-EC2-SG.id]
    subnet_id = aws_subnet.Linx-Private-SN[0].id
    # UserData to install NGINX
    user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF


    tags = {
        Name = "Linx-NginX"
    }
}
  
resource "aws_lb_target_group" "Linx-TG" {
    name = "Linx-TG"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = aws_vpc.Linx-VPC.id
}

resource "aws_lb_target_group_attachment" "Linx-TG-Attachment" {
    target_group_arn = aws_lb_target_group.Linx-TG.arn
    target_id = aws_instance.Linx-NginX.id
    port = 80
}

resource "aws_lb" "Linx-ALB" {
    name = "Linx-ALB"
    load_balancer_type = "application"
    security_groups = [aws_security_group.Linx-ALB-SG.id]
    subnets = aws_subnet.Linx-Public-SN[*].id

    tags = {
        Name = "Linx-ALB"
    }
}

resource "aws_lb_listener" "Linx-ALB-Listener" {
    load_balancer_arn = aws_lb.Linx-ALB.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.Linx-TG.arn
    }
}
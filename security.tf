# ALB Security Group
resource "aws_security_group" "Linx-ALB-SG" {
  name        = "Linx-ALB-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.Linx-VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Linx-ALB-SG"
  }
}

# EC2 Instance Security Group
resource "aws_security_group" "Linx-EC2-SG" {
    name        = "Linx-EC2-SG"
    description = "Allow HTTP inbound traffic"
    vpc_id      = aws_vpc.Linx-VPC.id

dynamic "ingress" {
    for_each = var.ports
    content {
        description      = "Allow HTTP, HTTPS, SSH inbound traffic"
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        security_groups  = [aws_security_group.Linx-ALB-SG.id]
        }
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

}


# Custom VPC
resource "aws_vpc" "ElizabethFolzGroup_VPC" {
  cidr_block       = var.VPC_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "ElizabethFolzGroup_VPC"
  }
}

# Two Public & Two Private Subnets in Diff AZ
resource "aws_subnet" "ElizabethFolzGroup_Public_SN1" {
  vpc_id            = aws_vpc.ElizabethFolzGroup_VPC.id
  cidr_block        = var.public_subnet1_cidr_block
  availability_zone = var.public_subnet1_availabilityzone

  tags = {
    Name = "ElizabethFolzGroup_Public_SN1"
  }
}

resource "aws_subnet" "ElizabethFolzGroup_Private_SN1" {
  vpc_id            = aws_vpc.ElizabethFolzGroup_VPC.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = var.private_subnet1_availabilityzone

  tags = {
    Name = "ElizabethFolzGroup_Private_SN1"
  }
}

resource "aws_subnet" "ElizabethFolzGroup_Public_SN2" {
  vpc_id            = aws_vpc.ElizabethFolzGroup_VPC.id
  cidr_block        = var.public_subnet2_cidr_block
  availability_zone = var.public_subnet2_availabilityzone

  tags = {
    Name = "ElizabethFolzGroup_Public_SN2"
  }
}

resource "aws_subnet" "ElizabethFolzGroup_Private_SN2" {
  vpc_id            = aws_vpc.ElizabethFolzGroup_VPC.id
  cidr_block        = var.private_subnet2_cidr_block
  availability_zone = var.private_subnet2_availabilityzone

  tags = {
    Name = "ElizabethFolzGroup_Private_SN2"
  }
}

# Custom Internet Gateway
resource "aws_internet_gateway" "ElizabethFolzGroup_IGW" {
  vpc_id = aws_vpc.ElizabethFolzGroup_VPC.id

  tags = {
    Name = "ElizabethFolzGroup_IGW"
  }
}

# Create a public route table
resource "aws_route_table" "ElizabethFolzGroup_Public_RT" {
  vpc_id = aws_vpc.ElizabethFolzGroup_VPC.id

  route {
    cidr_block = var.public_routetable_cidr_block
    gateway_id = aws_internet_gateway.ElizabethFolzGroup_IGW.id
  }

  tags = {
    Name = "ElizabethFolzGroup_Public_RT"
  }
}

# Public subnet1 attached to public route table
resource "aws_route_table_association" "ElizabethFolzGroup_Public_RTA1" {
  subnet_id      = aws_subnet.ElizabethFolzGroup_Public_SN1.id
  route_table_id = aws_route_table.ElizabethFolzGroup_Public_RT.id
}

# Public subnet2 attached to public route table
resource "aws_route_table_association" "ElizabethFolzGroup_Public_RTA2" {
  subnet_id      = aws_subnet.ElizabethFolzGroup_Public_SN2.id
  route_table_id = aws_route_table.ElizabethFolzGroup_Public_RT.id
}

# EIP for NAT Gateway
resource "aws_eip" "ElizabethFolzGroup_EIP" {
  vpc = true

  tags = {
    Name = "ElizabethFolzGroup_EIP"
  }
}

#Custom NAT Gateway
resource "aws_nat_gateway" "ElizabethFolzGroup_NGW" {
  allocation_id = aws_eip.ElizabethFolzGroup_EIP.id
  subnet_id     = aws_subnet.ElizabethFolzGroup_Public_SN1.id

  tags = {
    Name = "ElizabethFolzGroup_NGW"
  }
}

# Create a private route table
resource "aws_route_table" "ElizabethFolzGroup_Private_RT" {
  vpc_id = aws_vpc.ElizabethFolzGroup_VPC.id

  route {
    cidr_block     = var.private_routetable_cidr_block
    nat_gateway_id = aws_nat_gateway.ElizabethFolzGroup_NGW.id
  }

  tags = {
    Name = "ElizabethFolzGroup_Private_RT"
  }
}

# Private subnet1 attached to private route table
resource "aws_route_table_association" "ElizabethFolzGroup_Private_RTA1" {
  subnet_id      = aws_subnet.ElizabethFolzGroup_Private_SN1.id
  route_table_id = aws_route_table.ElizabethFolzGroup_Private_RT.id
}

# Private subnet2 attached to private route table
resource "aws_route_table_association" "ElizabethFolzGroup_Private_RTA2" {
  subnet_id      = aws_subnet.ElizabethFolzGroup_Private_SN2.id
  route_table_id = aws_route_table.ElizabethFolzGroup_Private_RT.id
}

# Two security groups (Frontend & Backend)
resource "aws_security_group" "ElizabethFolzGroup_Frontend_SG" {
  name        = "Frontend_Access"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.ElizabethFolzGroup_VPC.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All ICMP - IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ElizabethFolzGroup_Frontend_SG"
  }
}

resource "aws_security_group" "ElizabethFolzGroup_Backend_SG" {
  name        = "SSH_MYSQL_Access"
  description = "Enables SSH & MYSQL access"
  vpc_id      = aws_vpc.ElizabethFolzGroup_VPC.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  }

  ingress {
    description = "MYSQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ElizabethFolzGroup_Backend_SG"
  }
}


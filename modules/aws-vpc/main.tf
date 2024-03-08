# Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.vpc-name
  }
}
# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw-name
  }
  depends_on = [ aws_vpc.vpc ]
}
# Creating Public Subnet 
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.public-subnet1
  }
  depends_on = [ aws_internet_gateway.igw ]
}
# Creating Private Subnet 1 
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet1
  }


}

# Creating Private Subnet 2 
resource "aws_subnet" "private-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-cidr2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = var.private-subnet2
  }

  depends_on = [ aws_subnet.private-subnet1 ]
}


# Creating Elastic IP for NAT Gateway 1
resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = var.eip-name1
  }

  depends_on = [ aws_subnet.private-subnet2 ]
}

# Creating NAT Gateway 
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = var.ngw-name1
  }

  depends_on = [ aws_eip.eip1 ]
}
# Creating Public Route table 
resource "aws_route_table" "public-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name1
  }

  depends_on = [ aws_nat_gateway.ngw1 ]
}

# Associating the Public Route table to Public Subnet 
resource "aws_route_table_association" "public-rt-association1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt1.id

  depends_on = [ aws_route_table.public-rt1 ]
}
# Creating Private Route table 1
resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private-rt-name1
  }

  depends_on = [ aws_route_table_association.public-rt-association1 ]
}

# Associating the Private Route table 1 to Private Subnet 1
resource "aws_route_table_association" "private-rt-association1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt1.id

  depends_on = [ aws_route_table.private-rt1 ]
}

# Creating Private Route table 2 
resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name = var.private-rt-name2
  }

  depends_on = [ aws_route_table_association.private-rt-association1 ]
}

# Associating the Private Route table 2 to Private Subnet 2
resource "aws_route_table_association" "private-rt-association2" {
  subnet_id      = aws_subnet.private-subnet2.id 
  route_table_id = aws_route_table.private-rt2.id

  depends_on = [ aws_route_table.private-rt2 ]
}

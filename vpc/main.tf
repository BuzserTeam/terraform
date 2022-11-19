resource "aws_vpc" "buzser-dev" {
  cidr_block = var.main_vpc_cidr 
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "buzser-dev-igw" {
    vpc_id = aws_vpc.buzser-dev.id
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.buzser-dev.id 
    cidr_block = var.public_subnet
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.buzser-dev.id
  cidr_block = var.private_subnet
}

resource "aws_route_table" "BuzserPublicRT" {
  vpc_id = aws_vpc.buzser-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.buzser-dev-igw.id
  }
}
resource "aws_route_table" "BuzserPrivateRT" {
  vpc_id = aws_vpc.buzser-dev.id 
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.buzser_nat.id
  }
}

resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.BuzserPublicRT.id
}

resource "aws_route_table" "PrivateRTassociation" {
  vpc_id = aws_vpc.buzser-dev.id
}

resource "aws_eip" "buzser_eip" {
  vpc = true 
}
resource "aws_nat_gateway" "buzser_nat" {
   allocation_id = aws_eip.buzser_eip.id
   subnet_id = aws_subnet.public_subnet.id
}
resource "aws_vpc" "buzser" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.buzser.id
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.buzser.id
  availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "buzser_gateway" {
  vpc_id = aws_vpc.buzser.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.buzser.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

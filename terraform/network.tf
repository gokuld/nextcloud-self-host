resource "aws_vpc" "nextcloud_vpc" {
  cidr_block = "10.0.0.0/16"
}

#trivy:ignore:AVD-AWS-0164
resource "aws_subnet" "nextcloud_subnet_a" {
  vpc_id            = aws_vpc.nextcloud_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.aws_availability_zone_1

  map_public_ip_on_launch = true
}

resource "aws_subnet" "nextcloud_subnet_b" {
  vpc_id            = aws_vpc.nextcloud_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.aws_availability_zone_2
}

resource "aws_internet_gateway" "nextcloud_igw" {
  vpc_id = aws_vpc.nextcloud_vpc.id
}

resource "aws_route_table" "nextcloud_route_table" {
  vpc_id = aws_vpc.nextcloud_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextcloud_igw.id
  }
}

resource "aws_route_table_association" "nextcloud_route_table_assoc_a" {
  subnet_id      = aws_subnet.nextcloud_subnet_a.id
  route_table_id = aws_route_table.nextcloud_route_table.id
}

resource "aws_route_table_association" "nextcloud_route_table_assoc_b" {
  subnet_id      = aws_subnet.nextcloud_subnet_b.id
  route_table_id = aws_route_table.nextcloud_route_table.id
}

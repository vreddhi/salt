#Configure the VPC
resource "aws_vpc" "private-cloud" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
      Environment = "production"
      Project = "webapp"
  }

}

#Define subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id = "${aws_vpc.private-cloud.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability-zone}"

    tags = {
        Environment = "production"
        Project = "webapp"
    }

}

#Define private subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id = "${aws_vpc.private-cloud.id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "${var.availability-zone}"

  tags = {
      Environment = "production"
      Project = "webapp-migration"
  }

}


# Define a Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.private-cloud.id}"

    tags = {
        Environment = "production"
        Project = "webapp"
    }
    
}

# Establish route table, attaching Gateway to VPC
resource "aws_route_table" "main-route" {
  vpc_id = "${aws_vpc.private-cloud.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }
    tags = {
        Environment = "production"
        Project = "webapp"
    }

}

# Link the subnet with Route table
resource "aws_route_table_association" "public-subnet-link" {
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.main-route.id}"
}
resource "aws_security_group" "webapp-securitygroup" {
  vpc_id = "${aws_vpc.private-cloud.id}"
  name = "webapp-securitygroup"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
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
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Environment = "production"
      Project = "webapp"
  }

}

resource "aws_security_group" "sensor-securitygroup" {
  vpc_id = "${aws_vpc.private-cloud.id}"
  name = "sensor-securitygroup"
  description = "security group that allows access from webserver"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.webapp-securitygroup.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Environment = "production"
      Project = "webapp"
  }

}

#Allocate Elastic ips

data "aws_eip" "static_ip" {
  public_ip = "${var.ipaddress}"
}

data "aws_eip" "sensor_ip" {
  public_ip = "${var.sensor-ipaddress}"
}

resource "aws_eip_association" "sensor_eip_assoc" {
  instance_id   = aws_instance.sensor-instance.id
  allocation_id = "${data.aws_eip.sensor_ip.id}"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webapp-instance.id
  allocation_id = "${data.aws_eip.static_ip.id}"
}

#The ip address of EC2 server
output "webapp-ip" {
  value = ["${data.aws_eip.static_ip.public_ip}"]
}

#The ip address of EC2 server
output "sensor-ip" {
  value = ["${data.aws_eip.sensor_ip.public_ip}"]
}
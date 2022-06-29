#Allocate Elastic ip

data "aws_eip" "static_ip" {
  public_ip = "${var.ipaddress}"
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webapp-instance.id
  allocation_id = "${data.aws_eip.static_ip.id}"
}

#The ip address of EC2 server
output "webapp-ip" {
  value = ["${var.ipaddress}"]
}
resource "aws_ec2_traffic_mirror_filter" "filter" {
  description      = "traffic mirror filter - salt task"
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_filter_rule" "ruleout" {
  description              = "Outbound calls to port 80"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 6
  destination_port_range {
    from_port = 0
    to_port   = 80
  }  
}

resource "aws_ec2_traffic_mirror_target" "target" {
  network_interface_id = aws_instance.sensor-instance.primary_network_interface_id
}

resource "aws_ec2_traffic_mirror_session" "session" {
  description              = "traffic mirror session - salt task"
  network_interface_id     = aws_instance.webapp-instance.primary_network_interface_id
  session_number           = 1
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.target.id
}
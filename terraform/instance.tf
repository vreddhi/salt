#This file spins up a AWS instance from ami
#Creates a EBS and attaches itself to EC2 instance
#The EC2 is also associated to security group and launched in a subnet

#Define the AWS credentials to access resources
provider "aws" {
    region = "${var.region}"
    #shared_credentials_files = ["/Users/vbhat/Downloads/rootkey.csv"]
}

#Public Key used to upload to EC2 server to allow SSH connection
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCohqngBhm7TYBv+LXbsbHEHJiVkySAeegVbjqZK6XUR3r/KHRymB19+EXWyPHF5LBes3HBb7CbVr+LcyzCPsIYnaAMdm9C2edVbPQlQxc2lKtDBt+vxGX3rdg0ccEu1Qpt534+z3bhMW6kyXl9GGbLHstXfd+HuBYcvHtInoS/IbDhPy3sT2PDP6MTUvFFzxV/OB3mEp31DUNNpY1BLG8I8OL6v0L4lo1UhlwIgoyDm/4e/Rq0mTZBnKz1mcsMpEx3LQrZwUpBApEyS+3weGVC7jmBtSoRvcklHtS0YQG78h5TFaiEJ7qjo3qTZTGdfWMFn2d3mYW0v1AFJPW8uF8D vbhat@blr-mp1ou"
}


#Spin public facing EC2 instance
resource "aws_instance" "webapp-instance" {
    ami = "${var.ami-id}"
    instance_type = "${var.instance-type}"
    key_name = aws_key_pair.deployer.key_name
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    vpc_security_group_ids = ["${aws_security_group.webapp-securitygroup.id}"]  
    user_data = "${file("reverse_proxy.sh")}"
    #associate_public_ip_address = true  
    tags = {
        Environment = "production"
        Project = "webapp"
    }

}

#Spin a private EC2 instance
resource "aws_instance" "sensor-instance" {
    ami = "${var.ami-id}"
    instance_type = "${var.instance-type}"
    key_name = aws_key_pair.deployer.key_name
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    vpc_security_group_ids = ["${aws_security_group.sensor-securitygroup.id}"]  
    user_data = "${file("backup_pcap.sh")}"
    #associate_public_ip_address = false
    tags = {
        Environment = "production"
        Project = "webapp"
    }

}

#Spin a block store
resource "aws_ebs_volume" "webapp-data" {
  availability_zone = "${var.availability-zone}"
  size = 20
  type = "gp2"

  tags = {
      Environment = "production"
      Project = "webapp"
  }

}

#Attach or link the EBS with EC2
resource "aws_volume_attachment" "webapp-data-attachment" {
  device_name = "/dev/xvdh"
  volume_id = "${aws_ebs_volume.webapp-data.id}"
  instance_id = "${aws_instance.webapp-instance.id}"
  skip_destroy = true
}
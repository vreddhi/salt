# Define all the variables here

variable "ipaddress" {
    default = "54.167.235.53"
}

variable "sensor-ipaddress" {
    default = "3.89.77.39"
}

variable "region" {
    default = "us-east-1"
}

variable "availability-zone" {
    default = "us-east-1a"
}

variable "backup-availability-zone" {
    default = "us-east-1b"
}

variable "instance-type" {
    default = "t3.micro"
}

variable "ami-id" {
    default = "ami-052efd3df9dad4825"
}

variable "domain-name" {
    default = "securecodezone.com"
}

variable "sub-domain-name" {
    default = "www.securecodezone.com"
}
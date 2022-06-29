data "template_file" "ec2_user_data" {
  template = "${file("${path.module}/code.sh")}"
}
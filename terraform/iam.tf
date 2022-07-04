#Define a policy defining access to S3
resource "aws_iam_policy" "ec2-policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Ec2 policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
            "s3:Get*",
            "s3:List*",
            "s3:Put*",
            "kms:*"
            ]
            Effect   = "Allow"
            Resource = "*"
        }    
    ]
  })
}

#Define a role, and tell who can assume the role trusting it
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#Further attach the permission policy created above to the role
resource "aws_iam_policy_attachment" "ec2-policy-attach" {
  name       = "ec2-policy-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2-policy.arn
}

#Create an instance role profile, this is needed for EC2 to use or attach itself
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
data "aws_ami" "amazon_linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_s3_filipe"
  role = var.instance_role
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = var.instance_name
  }
}
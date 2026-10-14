#AMI
data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#default vpc
data "aws_vpc" "default" {
  default = true
}

#Default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#Default security group
data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.example.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  count         = var.instance_count
  depends_on    = [aws_efs_mount_target.example]

  #Mount EFS on EC2 instance
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nfs-common
    mkdir -p /mnt/efs
    mount -t nfs4 -o nfsvers=4.1 ${aws_efs_file_system.example.dns_name}:/ /mnt/efs
  EOF

  tags = {
    Name = "example-instance"
  }
}

resource "aws_efs_file_system" "example" {
  creation_token   = "example-token"
  performance_mode = "generalPurpose"
  tags = {
    Name = "example-efs"
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [data.aws_security_group.default.id]
}
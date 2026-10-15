#AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical oficial

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  count         = var.instance_count
  depends_on    = [aws_efs_mount_target.example]

  #Mount EFS on EC2 instance
  user_data = <<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get install -y nfs-common
  mkdir -p /mnt/efs
  
  EFS_HOST="${aws_efs_file_system.example.dns_name}"

  # Waiting DNS resolution for EFS hostname
  until getent hosts "$EFS_HOST" > /dev/null 2>&1; do
    echo "Waiting for DNS resolution for $EFS_HOST..."
    sleep 5
  done

  # Tries to mount the EFS filesystem until it succeeds
  until mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_HOST":/ /mnt/efs; do
    echo "Waiting for EFS mount..."
    sleep 5
  done
  EOF

  tags = {
    Name = "example-instance-${count.index + 1}"
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
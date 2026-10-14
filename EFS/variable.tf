variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}
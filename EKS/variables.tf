variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "eks_admins" {
  type = set(string)
  
}

variable "security_groups_ingress_ports" {
  description = "List of ports to allow ingress traffic in the EKS security group."
  type        = list(number)
  default     = [443, 80, 8888]
}

#Necessary for the EKS cluster to be created in a VPC with at least 2 subnets.
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS node group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 or more subnet IDs must be provided."
  }
}


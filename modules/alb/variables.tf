variable "subnets" {
  type = list(any)
  description = "Subnet to which ALB belongs."
}

variable "security_groups" {
  type = list(any)
  description = "Security groups to be added to ALB."
}

variable "certificate_arn" {
  description = "HTTPS listener certificate arn."
}

variable "vpc_id" {
  description = "VPC id."
}
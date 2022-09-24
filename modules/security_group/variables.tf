variable "name" {
  description = "Security group name."
}
variable "vpc_id" {
  description = "VPC id."
}
variable "port" {
  description = "Port number to allow communication."
}
variable "cidr_blocks" {
  type = list(string)
  description = "CIDR block to allow communication."
}

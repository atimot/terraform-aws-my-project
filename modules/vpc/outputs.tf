output "vpc_id" {
  value = aws_vpc.example.id
  description = "VPC id."
}

output "public_subnet_0_id" {
  value = aws_subnet.public_0.id
  description = "Public subnet id."
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1.id
  description = "Public subnet id."
}

output "private_subnet_0_id" {
  value = aws_subnet.private_0.id
  description = "Private subnet id."
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
  description = "Private subnet id."
}
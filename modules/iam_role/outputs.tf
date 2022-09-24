output "iam_role_arn" {
  value = aws_iam_role.default.arn
  description = "IAM role arn."
}

output "iam_role_name" {
  value = aws_iam_role.default.name
  description = "IAM role name"
}
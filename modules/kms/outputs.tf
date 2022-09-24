output "key_id" {
  value = aws_kms_key.example.key_id
  description = "KMS key id."
}

output "alias_id" {
  value = aws_kms_alias.example.id
  description = "KMS key alias id."
}
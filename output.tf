output "encryption_key_id" {
  description = "The id of the KMS Key for encryption and decryption of stored data"
  value       = module.encryption.key_id
}

output "encryption_key_arn" {
  description = "The ARN of the KMS Key for encryption and decryption of stored data"
  value       = module.encryption.key_arn
}

output "table" {
  description = "The ARN of the DynamoDB Table for keyvalue storage"
  value       = aws_dynamodb_table.keyvalue.arn
}

output "table_id" {
  description = "The name of the DynamoDB table for keyvalue storage"
  value       = aws_dynamodb_table.keyvalue.id
}

output "table_endpoint" {
  description = "The VPC Endpoint for DynamoDB (key-value)"
  value       = "dynamodb.${local.region}.amazonaws.com"
}

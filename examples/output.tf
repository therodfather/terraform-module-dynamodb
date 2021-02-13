output "namespace" {
  description = "Namespace module output"
  value       = module.namespace
}

output "table" {
  description = "The ARN of the DynamoDB Table for keyvalue storage"
  value       = module.dynamodb.table
}

output "table_endpoint" {
  description = "The VPC Endpoint for DynamoDB (key-value)"
  value       = module.dynamodb.table_endpoint
}

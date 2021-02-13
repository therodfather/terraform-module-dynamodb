# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  namespace  = lower("${var.namespace}-${var.name}")
}

#Create a KMS Key
module "encryption" {
  source     = "../"
  name       = var.name
  namespace  = local.namespace
  tags       = var.tags
  encryptors = var.encryptors
  decryptors = var.decryptors
}

resource "aws_dynamodb_table" "keyvalue" {
  name             = local.namespace
  stream_enabled   = var.global_tables_enabled ? true : false
  stream_view_type = var.global_tables_enabled ? var.stream_view_type : null
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = var.hash_key
  range_key        = var.range_key_enabled ? var.range_key : null

  # Required block for hash key attribute
  attribute {
    name = var.hash_key
    type = "S"
  }

  # Optional block for range key attribute (if used)
  dynamic "attribute" {
    for_each = var.range_key_enabled ? [var.range_key] : []
    content {
      name = attribute.value
      type = "S"
    }
  }

  # Block for building any other attributes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = lookup(attribute.value, "name")
      type = upper(lookup(attribute.value, "type"))
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.lsi_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.gsi_map
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
    }
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.global_tables_enabled ? null : module.encryption.key_arn
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  dynamic "replica" {
    for_each = var.global_tables_enabled ? var.global_tables_replica_regions : []
    content {
      region_name = replica.value
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  tags = var.tags
}
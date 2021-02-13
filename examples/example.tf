provider "aws" {
  region = var.region
}

module "namespace" {
  source              = "../"
  owner               = "cloud-patterns"
  application_name    = "eto"
  service_name        = "storage-demo"
  application_id      = "104284"
  workspace           = terraform.workspace
  data_classification = "Proprietary"
  scm_branch          = var.scm_branch
  scm_commit_id       = var.scm_commit_id
  scm_project         = var.scm_project
  scm_repo            = var.scm_repo
  issrcl_level        = "Low"
  environment         = var.environment
}

# Advanced key-value example (Dynamodb only)
module "dynamodb" {
  source     = "../"
  namespace  = module.namespace.lower_short_name
  name       = "test"
  tags       = module.namespace.tags

  global_tables_enabled = true

  range_key_enabled = true

  # Be sure to see notes on readme on attributes
  attributes = [
    {
      name = "Average"
      type = "N"
    },
    {
      name = "Max"
      type = "N"
    },
    {
      name = "Min"
      type = "N"
    },
    {
      name = "Info"
      type = "S"
    }
  ]

  # In the indexes below, note that "id" and "timestamp" are the default values for hash_key and range_key
  # These can changed by using the hash_key and range_key, respectively, and those new values if used, would be suitable for use in any additional indexes
  lsi_map = [
    {
      name               = "MinSortIndex"
      range_key          = "Min"
      projection_type    = "INCLUDE"
      non_key_attributes = ["id", "Info"]
    },
    {
      name               = "MaxSortIndex"
      range_key          = "Max"
      projection_type    = "INCLUDE"
      non_key_attributes = ["id", "Info"]
    }
  ]

  gsi_map = [
    {
      name               = "AverageInfoIndex"
      hash_key           = "Average"
      range_key          = "Info"
      write_capacity     = 5
      read_capacity      = 5
      projection_type    = "INCLUDE"
      non_key_attributes = ["id", "timestamp"]
    }
  ]
}

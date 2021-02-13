variable "namespace" {
  description = "A namespace value for naming created resources"
  type        = string
}

variable "name" {
  description = "A name value for naming created resources"
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment name to use for resolving variables"
  default     = "default"
}

variable "tags" {
  description = "A map of tags for tagging created resources"
  type        = map
}

variable "decryptors" {
  description = "A list of roles that should be allowed to read from encrypted data resources"
  type        = list(string)
  default     = []
}

variable "encryptors" {
  description = "A list of roles that should be allowed to write to encrypted data resources"
  type        = list(string)
  default     = []
}

###################################
# DynamoDB Variables
###################################

variable "hash_key" {
  description = "The (optional) name of the DynamoDb table string hash key"
  type        = string
  default     = "id"
}

variable "range_key" {
  description = "The (optional) name of the DynamoDb table string range key"
  type        = string
  default     = "timestamp"
}

variable "range_key_enabled" {
  description = "The (optional) flag that specifies whether to use the range_key"
  type        = bool
  default     = false
}

variable "attributes" {
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery (NOTE that it can take up to 10 minutes to enable for new tables)"
  type        = bool
  default     = false
}

variable "gsi_map" {
  description = "Additional global secondary indexes in the form of a list of mapped values"
  type = list(object({
    hash_key           = string
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
    read_capacity      = number
    write_capacity     = number
  }))
  default = []
}

variable "lsi_map" {
  description = "Additional local secondary indexes in the form of a list of mapped values"
  type = list(object({
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
  }))
  default = []
}

variable "global_tables_enabled" {
  description = "Boolean to enable Global Tables v2 with regional replicas"
  type        = bool
  default     = false
}

variable "global_tables_replica_regions" {
  description = "Boolean to enable Global Tables v2 with regional replicas"
  type        = list
  default     = ["us-west-2"]
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

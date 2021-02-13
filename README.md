# terraform-modules-aws-dynamodb

This Terraform module deploys a single DynamoDB to the target account.

## Why Should I Use This

Several reasons, but most importantly...

* It provides a simple to adopt interface to deploy the DynamoSB you need for your applicaiton

* It meets all governance and security requirements of EA

* It includes features that allow for easy integration into existing access logging for auditing and monitoring

* It enables encryption at rest by default

## Module Limitations

* This module does not, and will not, provide a means to deploy any storage with public access

* This module only supports DynamoDB Global Tables V2 (version 2019.11.21).  There are no plans to support v1 tables.

* This module only supports DynamoDB On-Demand ("PAY\_PER\_REQUEST") Billing Mode at this time.

## Resource Considerations

### Key-Value (DynamoDB)

* The VPC Endpoint must be used when accessing DynamoDB.  This is provided via the output attribute `table_endpoint` in this module.  See [Using Amazon VPC Endpoints to Access DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/vpc-endpoints-dynamodb.html) for more information.

* Direct access to data housed in DynamoDB through federation is prohibited.  AWS IAM Roles and Policies with least privileged access must be used.

* Local Secondary Indexes must be added at the time of table creation.  If they are added later, this will cause new resources and may result in data loss!

* Global Secondary Indexes can be added at any time without the potential of new resource creation (data loss), but they only support Eventual Consistency.

* A note regarding additional attributes (not Hash or Range Keys):

  You do not have to define every attribute you want to use up front when creating your table.  `attribute` blocks inside aws\_dynamodb\_table resources are not defining which attributes you can use in your application.  They are defining the key schema for the table and indexes.  This means that it would make up a Primary Key (Hash Key + Range Key) for an LSI or GSI.

* For On-Demand (PAY\_PER\_REQUEST) Billing Mode, you don't need to specify how much read or write throughput you expect your application to need.  You are charged for the reads and writes that your application performs on your tables in terms of Read and Write Request Units (RRU and WRU, respectively).

* Information about Read Capacity Units

  * 1 Read Capacity Unit (RCU) = 1 strongly consistent read of up to 4 KB/s (or 2 eventually consistent reads of up to 4 KB/s per read)

  * 2 RCUs = 1 transactional read request (one read per second) for items up to 4 KB

  * For reads of items > 4 KB, total number of reads required = (Total Item Size / 4 KB) rounded up

* Information about Write Capacity Units

  * 1 Write Capacity Unit (WCU) = 1 write of up to 1 KB/s

  * 2 WCUs = 1 transactional write request (1 write per second) for items up to 1 KB.

  * For writes > 1 KB, total number of writes required = (Total Item Size / 1 KB) rounded up

## Usage

THe following code sample will produce a DynamoDB table.

Please note that this module does not include a versions.tf file. There are no provider constraints/dependencies for the module at this time.  
The consumers of this module are encouraged to use the latest versions of providers that are available.

### Sample Declaration

```hcl
provider "aws" {
  region = var.region
}

module "namespace" {
  source              = "../"
  owner               = "cloud-patterns"
  application_name    = "testapp"
  service_name        = "storage-demo"
  application_id      = "111111"
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

```

For more advanced usage, see the `examples` folders

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional DynamoDB attributes in the form of a list of mapped values | <pre>list(object({<br>    name = string<br>    type = string<br>  }))</pre> | `[]` | no |
| decryptors | A list of roles that should be allowed to read from encrypted data resources | `list(string)` | `[]` | no |
| encryptors | A list of roles that should be allowed to write to encrypted data resources | `list(string)` | `[]` | no |
| environment | The environment name to use for resolving variables | `string` | `"default"` | no |
| global\_tables\_enabled | Boolean to enable Global Tables v2 with regional replicas | `bool` | `false` | no |
| global\_tables\_replica\_regions | Boolean to enable Global Tables v2 with regional replicas | `list` | <pre>[<br>  "us-west-2"<br>]</pre> | no |
| gsi\_map | Additional global secondary indexes in the form of a list of mapped values | <pre>list(object({<br>    hash_key           = string<br>    name               = string<br>    non_key_attributes = list(string)<br>    projection_type    = string<br>    range_key          = string<br>    read_capacity      = number<br>    write_capacity     = number<br>  }))</pre> | `[]` | no |
| hash\_key | The (optional) name of the DynamoDb table string hash key | `string` | `"id"` | no |
| lsi\_map | Additional local secondary indexes in the form of a list of mapped values | <pre>list(object({<br>    name               = string<br>    non_key_attributes = list(string)<br>    projection_type    = string<br>    range_key          = string<br>  }))</pre> | `[]` | no |
| name | A name value for naming created resources | `string` | n/a | yes |
| namespace | A namespace value for naming created resources | `string` | n/a | yes |
| point\_in\_time\_recovery | Whether to enable point-in-time recovery (NOTE that it can take up to 10 minutes to enable for new tables) | `bool` | `false` | no |
| range\_key | The (optional) name of the DynamoDb table string range key | `string` | `"timestamp"` | no |
| range\_key\_enabled | The (optional) flag that specifies whether to use the range\_key | `bool` | `false` | no |
| stream\_view\_type | When an item in the table is modified, StreamViewType determines what information is written to the table's stream | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| tags | A map of tags for tagging created resources | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| encryption\_key\_arn | The ARN of the KMS Key for encryption and decryption of stored data |
| encryption\_key\_id | The id of the KMS Key for encryption and decryption of stored data |
| table | The ARN of the DynamoDB Table for keyvalue storage |
| table\_endpoint | The VPC Endpoint for DynamoDB (key-value) |
| table\_id | The name of the DynamoDB table for keyvalue storage |


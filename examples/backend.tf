terraform {
    backend "s3" {
    bucket         = "mybucket-tf-states"
    region         = "us-east-1"
    key            = "dynanodb-examples/terraform.tfstate"
    dynamodb_table = "mytable-tf-locks"
    encrypt        = true
  }
}
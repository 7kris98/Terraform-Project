
terraform {
  backend "s3" {
    bucket = "acs730-assignment1"     // Bucket where to SAVE Terraform State
    key    = "Prod/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"              // Region where bucket is created
  }
}

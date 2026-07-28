# Points at the S3 bucket + DynamoDB table created once by
# terraform/backend-setup/. Fill in the bucket name you actually created.

terraform {
    backend "s3" {
        bucket = "clickncart-terraform-state-12345"
        key = "environments/dev/terraform.tfstate"
        dynamodb_table = "clickncart-terraform-lock"
        encrypt = true

    }
}
terraform {
  backend "s3" {
    bucket = "clickncart-state-file-locking-bucket"
    key    = "clickncart/dev/terraform.tfstate"
    region = "us-east-1"

    use_lockfile = true
  }
}
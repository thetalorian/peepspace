provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

terraform {
    backend "s3" {
        encrypt = true
        bucket = "terraform-backend-happy-fun-times"
        region = "us-east-1"
        key = "statepath"
    }
}
provider "aws" {
  region     = "us-east-1"
}

provider "kubernetes" {
  host                   = "${module.eks.cluster_endpoint}"
  cluster_ca_certificate = "${module.eks.cluster_cert}"
  token                  = "${module.eks.cluster_token}"
  load_config_file       = false
}

terraform {
    backend "s3" {
        encrypt = true
        bucket = "terraform-backend-happy-fun-times"
        region = "us-east-1"
        key = "statepath"
    }
}
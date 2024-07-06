provider "aws" {
  profile = var.profile
  region  = var.region
}

provider "aws" {
  profile = var.profile
  region  = "us-east-1"
  alias   = "us-east-1-prov"
}

provider "aws" {
  profile = var.profile
  region  = "eu-west-1"
  alias = "euw1-prov"
}

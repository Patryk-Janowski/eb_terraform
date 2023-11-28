

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket-gqo9293j"
    key            = "secure-eb/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table-gqo9293j"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "terraform-remote-state-abc123abc"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = local.env_code
      Terraform   = true
    }
  }
}

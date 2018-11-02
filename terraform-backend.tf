terraform {
  backend "s3" {
    bucket         = "zikarad-deployments"
    key            = "state/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "deployments"
  }
}

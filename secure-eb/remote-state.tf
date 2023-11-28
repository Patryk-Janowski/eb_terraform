data "terraform_remote_state" "eb_env_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-gqo9293j"
    key    = "create-eb/terraform.tfstate"
    region = "us-west-2"
  }
}
# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "xyz"
  secret_key = "xyz"
}

terraform {
  backend "s3" {
    bucket = "sockshop.tf.state"
    region = "us-east-1"
    key = "jenkins-server/terraform.tfstate"
  }
}
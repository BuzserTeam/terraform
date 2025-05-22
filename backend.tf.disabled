terraform {
  backend "s3" {
    bucket         = "buzser-terraform-state"
    key            = "terraform/state/buzser.tfstate"
    region         = "us-east-1"  # Adjust to your preferred region
    dynamodb_table = "buzser-terraform-locks"
    encrypt        = true
  }
}
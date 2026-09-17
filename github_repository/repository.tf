resource "github_repository" "terraform_repo" {
  name        = "terraform_created_repo"
  description = "Terraform repository for AWS EC2 instance"
  visibility  = "public"

  topics = ["terraform", "aws"]

}
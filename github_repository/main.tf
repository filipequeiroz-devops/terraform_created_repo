terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.61.0"
        }

        github = {
            source  = "integrations/github"
            version = "5.13.0"
        }
    }
}

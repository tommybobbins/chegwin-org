module "website" {
  source = "./modules/s3_cloudfront"

  # Common parameters you might want to configure
  domain_name       = var.domain_name
  github_repository = var.github_repository
  create_github_oidc = var.create_github_oidc

  common_tags = {
    Environment = "production"
    Project     = replace(var.domain_name, ".", "-")
    Terraform   = "true"
  }
}

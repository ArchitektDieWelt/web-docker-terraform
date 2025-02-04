module "s3_source_bucket" {
  source  = "./s3"

  name        = var.source_bucket_name
  project     = var.project
  environment = var.environment
  description = var.description

  versioning  = true
  require_tls = true
}

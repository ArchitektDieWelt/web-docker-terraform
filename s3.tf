module "s3_source_bucket" {
  source  = "./s3"

  name        = "webdocker-s3-source-bucket"
  project     = var.project
  environment = var.environment
  description = var.description

  versioning  = true
  require_tls = true
}

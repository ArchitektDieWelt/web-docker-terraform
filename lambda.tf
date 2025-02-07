module "webdocker_lambda" {
  source  = "./lambda"

  name                         = var.lambda_name
  gitName                      = var.bucket_key_prefix
  project                      = var.project
  environment                  = var.environment
  description                  = var.description
  ref                          = var.lambda_script_reference
  policy                       = data.aws_iam_policy_document.webdocker_exec_policy.json
  bucket                       = var.lambda_bucket
  handler                      = "index.handler"
  source_arn                   = ""
  source_principal             = ""
  timeout                      = 30
  runtime                      = "nodejs16.x"

  environmentVariables = {
    DESTINATION_BUCKET_NAME         = var.destination_bucket_name
    DESTINATION_CONFIGS_ASSET_KEY = var.s3_destination_configs_asset_key
    CLOUDFRONT_DISTRIBUTION_ID    = var.cloudfront_distribution_id
    CLOUDFRONT_INVALIDATION_PATH  = "/${var.s3_destination_configs_asset_key}"
  }
}

variable "aws_region" { default = "eu-central-1" }
variable "lambda_script_reference" {
  default = "latest.zip"
}
variable "project" {
  default = "web-docker"
}
variable "environment" {}

variable "description" {
  default = "Lambda to merge webdocker configurations to one general json config"
}

variable "lambda_bucket" {}

variable "lambda_name" {
    default = "webdocker-config-update"
}

variable "source_bucket_name" {
  type = string
  default = "webdocker-s3-source-bucket"
  description = "the bucket name for bucket that will hold partial configurations, will be created by terraform"
}

variable "s3_destination_configs_asset_key" {
  description = "the concatenated config file path used by the webdocker - destination"
  type        = string
  default = "web-assets/webdocker/configs.json"
}

variable "destination_bucket_arn" {
    description = "the bucket arn where the webdocker config is stored"
    type        = string
}

variable "destination_bucket_name" {
  description = "the bucket name where the webdocker config is stored"
  type        = string
}


variable "cloudfront_distribution_id" {
    description = "the cloudfront distribution id for invalidation of aggregated configs"
    type        = string
}

variable "cloudfront_distribution_arn" {
  description = "the cloudfront distribution arn of the VPC"
  type        = string
}

variable "aws_account_id" {
  type = string
}

variable "iam_config_deployer_user_name" {
  type = string
  description = "name of the user that will be created to use for config updates in s3"
  default = "update-webdocker-config-pipeline-user"
}

variable "config_bucket_update_policy_name" {
  type = string
  default = "update-webdocker-config-pipeline-policy"
  description = "name for the policy that allows access for the deployer user to the source s3 bucket"
}

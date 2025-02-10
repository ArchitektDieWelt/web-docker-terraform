variable "name" {}
variable "project" {}
variable "environment" {}

variable "description" {}

variable "ref" {
  default = "latest.zip"
}

variable "policy_file" {
  type    = string
  default = ""
}
variable "policy" {
  type    = string
  default = ""
}

variable "source_arn" {}
variable "source_account" {
  description = "account id of the AWS account that can trigger this lambda"
  type        = string
  default     = null
}
variable "source_principal" {}
variable "bucket" {
    description = "The S3 bucket to store the lambda code"
    type        = string
    default = "webdocker-test-public"
}
variable "handler" { default = "main.handler" }
variable "runtime" { default = "nodejs18.x" }
variable "environmentVariables" {
  type    = map(any)
  default = { "foo" = "bar" }
}
variable "subnet_ids" {
  type    = list(any)
  default = []
}
variable "security_group_ids" {
  type    = list(any)
  default = []
}
variable "timeout" { default = 60 }
variable "concurrent_executions" { default = -1 }
variable "memory_size" { default = 128 }
variable "sns_error_notification_topics" { default = [] }
variable "layers" {
  description = "A list of ARNs of Lambda Layers that this lambda builds upon"
  type        = list(string)
  default     = []
}

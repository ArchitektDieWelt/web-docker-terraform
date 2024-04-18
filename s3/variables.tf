variable "name" {
}

variable "project" {
}

variable "environment" {
}

variable "description" {
}

variable "acl" {
  default = "private"
}

variable "kms_key_arn" {
  default = ""
}

variable "versioning" {
  description = "if this is falsy, this sets a tag that excludes this bucket from AWS Backup"
}

variable "use_default_lifecycle_policies" {
  description = "whether or not to create the default lifecycle policies that archive then delete old versions of objects"
  default     = true
  type        = bool
}

variable "require_tls" {
  description = "only allow secure communication"
  type        = bool
  default     = false
}

variable "backup" {
  description = "sets a tag on the bucket that, if set to false, effectively excludes this bucket from S3 backups. Only used if versioning is enabled"
  type        = bool
  default     = true
}

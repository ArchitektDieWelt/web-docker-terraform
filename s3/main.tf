resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.name
  acl           = var.acl

  versioning {
    enabled = var.versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = var.kms_key_arn == "" ? "AES256" : "aws:kms"
      }
    }
  }

  tags = {
    Name        = "s3_bucket-${var.name}"
    Type        = var.name
    Project     = var.project
    Environment = var.environment
    Note        = var.description

    Backup = var.versioning == true ? var.backup : false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  # only create this resource if it is desired by the caller
  count  = var.use_default_lifecycle_policies == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "transition_to_IA_storage_class"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  dynamic "rule" {
    for_each = var.versioning == true ? ["versioning"] : []
    content {
      id     = "archive_then_delte_old_versions"
      status = "Enabled"

      # move old versions to a cheaper, slower storage tier
      noncurrent_version_transition {
        noncurrent_days = 30
        storage_class   = "STANDARD_IA"
      }

      noncurrent_version_expiration {
        noncurrent_days           = 180
        newer_noncurrent_versions = 5
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-public-access" {
  count  = var.acl == "public-read" ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.acl == "public-read" || var.require_tls == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy[count.index].json
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.acl == "public-read" || var.require_tls == true ? 1 : 0
  dynamic "statement" {
    for_each = toset(var.acl == "public-read" ? ["singleton_public_policy"] : [])

    content {
      sid = "PublicRead"

      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:GetObjectVersion"]
      resources = ["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"]

      principals {
        type        = "*"
        identifiers = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = toset(var.require_tls == true ? ["singleton_tls_policy"] : [])
    content {
      sid = "AllowSSLRequestsOnly"

      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*"
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }

      principals {
        type        = "*"
        identifiers = ["*"]
      }
    }
  }
}

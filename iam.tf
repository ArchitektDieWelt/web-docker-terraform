data "aws_iam_policy_document" "webdocker_exec_policy" {
  statement {
    sid    = "Logging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    sid    = "invalidate"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations"
    ]
    resources = [var.cloudfront_distribution_arn]
  }
  statement {
    sid    = "s3destinationGetPut"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${var.destination_bucket_arn}/${var.s3_destination_configs_asset_key}"]
  }
  statement {
    sid    = "s3destinationList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [var.destination_bucket_arn]
  }
  statement {
    sid    = "s3SourceGet"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${module.s3_source_bucket.arn}/*"]
  }
  statement {
    sid    = "s3SourceList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [module.s3_source_bucket.arn]
  }
}

resource "aws_iam_user" "configs_deployer_user" {
  name = var.iam_config_deployer_user_name
}

resource "aws_iam_user_policy_attachment" "configs_deployer_user_policy" {
  user   = aws_iam_user.configs_deployer_user.name
  policy_arn = aws_iam_policy.update-webdocker-config-pipeline-policy.arn
}

resource "aws_iam_policy" "update-webdocker-config-pipeline-policy" {
  name        = var.config_bucket_update_policy_name
  description = "Policy to upload into configuration bucket"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "s3:PutAnalyticsConfiguration",
          "s3:PutAccessPointConfigurationForObjectLambda",
          "s3:GetObjectVersionTagging",
          "s3:DeleteAccessPoint",
          "s3:CreateBucket",
          "s3:DeleteAccessPointForObjectLambda",
          "s3:GetStorageLensConfigurationTagging",
          "s3:ReplicateObject",
          "s3:GetObjectAcl",
          "s3:GetBucketObjectLockConfiguration",
          "s3:DeleteBucketWebsite",
          "s3:GetIntelligentTieringConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetObjectVersionAcl",
          "s3:DeleteObject",
          "s3:GetBucketPolicyStatus",
          "s3:GetObjectRetention",
          "s3:GetBucketWebsite",
          "s3:GetJobTagging",
          "s3:PutReplicationConfiguration",
          "s3:GetObjectAttributes",
          "s3:PutObjectLegalHold",
          "s3:InitiateReplication",
          "s3:GetObjectLegalHold",
          "s3:GetBucketNotification",
          "s3:PutBucketCORS",
          "s3:DescribeMultiRegionAccessPointOperation",
          "s3:GetReplicationConfiguration",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutBucketNotification",
          "s3:DescribeJob",
          "s3:PutBucketLogging",
          "s3:GetAnalyticsConfiguration",
          "s3:PutBucketObjectLockConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetAccessPointForObjectLambda",
          "s3:GetStorageLensDashboard",
          "s3:CreateAccessPoint",
          "s3:GetLifecycleConfiguration",
          "s3:GetInventoryConfiguration",
          "s3:GetBucketTagging",
          "s3:PutAccelerateConfiguration",
          "s3:GetAccessPointPolicyForObjectLambda",
          "s3:DeleteObjectVersion",
          "s3:GetBucketLogging",
          "s3:ListBucketVersions",
          "s3:RestoreObject",
          "s3:ListBucket",
          "s3:GetAccelerateConfiguration",
          "s3:GetObjectVersionAttributes",
          "s3:GetBucketPolicy",
          "s3:PutEncryptionConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetObjectVersionTorrent",
          "s3:AbortMultipartUpload",
          "s3:GetBucketRequestPayment",
          "s3:GetAccessPointPolicyStatus",
          "s3:UpdateJobPriority",
          "s3:GetObjectTagging",
          "s3:GetMetricsConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:ListBucketMultipartUploads",
          "s3:PutIntelligentTieringConfiguration",
          "s3:GetAccessPointPolicyStatusForObjectLambda",
          "s3:PutMetricsConfiguration",
          "s3:PutBucketOwnershipControls",
          "s3:UpdateJobStatus",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetAccessPointConfigurationForObjectLambda",
          "s3:PutInventoryConfiguration",
          "s3:GetObjectTorrent",
          "s3:GetStorageLensConfiguration",
          "s3:DeleteStorageLensConfiguration",
          "s3:PutBucketWebsite",
          "s3:PutBucketRequestPayment",
          "s3:PutObjectRetention",
          "s3:CreateAccessPointForObjectLambda",
          "s3:GetBucketCORS",
          "s3:GetBucketLocation",
          "s3:GetAccessPointPolicy",
          "s3:ReplicateDelete",
          "s3:GetObjectVersion"
        ],
        "Resource": [
          "${module.s3_source_bucket.arn}/*",
          module.s3_source_bucket.arn,
          "arn:aws:s3:*:${var.aws_account_id}:storage-lens/*",
          "arn:aws:s3:us-west-2:${var.aws_account_id}:async-request/mrap/*/*",
          "arn:aws:s3:::*/*",
          "arn:aws:s3:*:${var.aws_account_id}:job/*",
        ]
      },
      {
        "Sid": "VisualEditor2",
        "Effect": "Allow",
        "Action": [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob"
        ],
        "Resource": "*"
      }
    ]
  })
}

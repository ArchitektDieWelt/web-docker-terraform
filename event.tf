resource "aws_s3_bucket_notification" "webDockerTrigger" {
  bucket = module.s3_source_bucket.id

  lambda_function {
    lambda_function_arn = module.webdocker_lambda.lambda_function-arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:ObjectRestore:Completed"]
  }
}

resource "aws_lambda_permission" "config_updated_webdocker" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "s3.amazonaws.com"
}

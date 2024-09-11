#----------------------
# Lambda関数デプロイ
#----------------------

# Lambda関数定義

resource "aws_lambda_function" "lambda_efs_mv_01" {
  function_name = "${var.project}-${var.env}-efs-mv-01"
  s3_bucket     = aws_s3_bucket.lambda_code_store.bucket
  s3_key        = "lambda_code.zip"

  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 60
  role    = aws_iam_role.lambda_role_01.arn

  vpc_config {
    subnet_ids         = [data.aws_subnet.private-1a.id, data.aws_subnet.private-1c.id]
    security_group_ids = [aws_security_group.efs_sg_01.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.access_point.arn
    local_mount_path = "/mnt/efs"
  }
}

# S3からLambda関数呼び出しを許可

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_efs_mv_01.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_store.arn
}
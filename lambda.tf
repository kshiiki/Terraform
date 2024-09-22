#----------------------
# Lambda関数デプロイ
#----------------------

# Lambda関数定義

data "archive_file" "source_lambda_efs" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/lambda_function.zip"
}

resource "aws_lambda_function" "lambda_efs_mv_01" {
  function_name    = "${var.project}-${var.env}-efs-mv-01"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 600
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_role_01.arn
  filename         = data.archive_file.source_lambda_efs.output_path
  source_code_hash = data.archive_file.source_lambda_efs.output_base64sha256

  vpc_config {
    subnet_ids         = [data.aws_subnet.private-1a.id, data.aws_subnet.private-1c.id]
    security_group_ids = [aws_security_group.efs_sg_01.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.access_point.arn
    local_mount_path = "/mnt/efs"
  }

  environment {
    variables = {
      DIRECTORY_NAME  = "upload"
      EFS_MOUNT_POINT = "/efs"
      RETRY_COUNT     = "3"
      SLEEP_TIME      = "10"
    }
  }

  depends_on = [aws_efs_mount_target.orion-efs-1a,aws_efs_mount_target.orion-efs-1c]
}

# S3からLambda関数呼び出しを許可

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_efs_mv_01.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_store.arn
}
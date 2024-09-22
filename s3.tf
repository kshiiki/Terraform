#-------------------
# データ格納用 S3
#-------------------

resource "aws_s3_bucket" "data_store" {
  bucket              = "${var.project}-${var.env}-data-store-01"
  object_lock_enabled = false
  force_destroy       = true

  tags = {
    Name = "${var.project}-${var.env}-data-store-01"
  }
}

# ACL無効化
resource "aws_s3_bucket_ownership_controls" "data_store" {
  bucket = aws_s3_bucket.data_store.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# BlockPublicAccess disabled

resource "aws_s3_bucket_public_access_block" "data_store" {
  bucket                  = aws_s3_bucket.data_store.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# デフォルト暗号化 (SSE-S3)

resource "aws_s3_bucket_server_side_encryption_configuration" "data_store" {
  bucket = aws_s3_bucket.data_store.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

#------------------------
# S3イベント通知
#------------------------

resource "aws_s3_bucket_notification" "bucket_notification_lambda" {

  bucket = aws_s3_bucket.data_store.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_efs_mv_01.arn
    events              = ["s3:ObjectCreated:Post","s3:ObjectCreated:Put"]
    filter_prefix       = "upload/test"
  }

  depends_on = [aws_lambda_function.lambda_efs_mv_01, aws_lambda_permission.s3]
}

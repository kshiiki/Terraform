#-----------------------
# Lambda用ロググループ
#-----------------------

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_efs_mv_01.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name = "efs_move_lambda_logstream"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
}
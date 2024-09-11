#----------------------------
# Lambda用IAMロール作成
#----------------------------

resource "aws_iam_role" "lambda_role_01" {
  name = "${var.project}-${var.env}-lambda-role-01"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

#----------------------------
# Lambda用IAMポリシー作成
#----------------------------

resource "aws_iam_policy" "lambda_policy_01" {
  name = "${var.project}-${var.env}-lambda-policy-01"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "efs:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
        ],
        "Resource" : "*"
      }
    ]
  })
}

#--------------------------
# IAMポリシーアタッチメント
#--------------------------

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_01" {
  role       = aws_iam_role.lambda_role_01.name
  policy_arn = aws_iam_policy.lambda_policy_01.arn
}


#-------------------------
# Image builder用 ロール作成
#-------------------------

resource "aws_iam_role" "ec2_role_01" {
  name = "${var.project}-${var.env}-cicd-role-01"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

#--------------------------
# IAMポリシーアタッチメント
#--------------------------

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment_01" {
  role       = aws_iam_role.ec2_role_01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment_02" {
  role       = aws_iam_role.ec2_role_01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment_03" {
  role       = aws_iam_role.ec2_role_01.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

#------------------------
# Instanceプロファイル
#------------------------

resource "aws_iam_instance_profile" "ec2_profile_01" {
  name = "${var.project}-${var.env}-ec2-instance-profile-01"
  role = aws_iam_role.ec2_role_01.name
}
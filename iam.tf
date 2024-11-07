resource "aws_iam_user" "s3_user" {
  name = "singsong_s3_user"
}

resource "aws_iam_user_policy" "s3_user_policy" {
  user = aws_iam_user.s3_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.singsong_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.singsong_bucket.id}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}

# Access Key를 SSM Parameter Store에 저장
resource "aws_ssm_parameter" "s3_access_key_id" {
  name  = "/singsong/AWSAccessKeyId"
  type  = "String"
  value = aws_iam_access_key.s3_user_access_key.id
}

# Secret Key를 SSM Parameter Store에 저장
resource "aws_ssm_parameter" "s3_secret_access_key" {
  name  = "/singsong/AWSSecretAccessKey"
  type  = "SecureString"  # 보안 강화를 위해 SecureString으로 설정
  value = aws_iam_access_key.s3_user_access_key.secret
}
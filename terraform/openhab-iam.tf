resource "aws_iam_user" "openhab_user" {
    name = "openhab"
    force_destroy = false
    tags = {
        "billingtag" = "openhab"
    }
}

resource "aws_iam_access_key" "openhab_user_key" {
    user = aws_iam_user.openhab_user.name
}

output "openhab_user_key_id" {
    value = aws_iam_access_key.openhab_user_key.id
}

output "openhab_user_key_secret" {
    value = aws_iam_access_key.openhab_user_key.secret
    sensitive = true
}

resource "aws_iam_policy" "openhab_user_policy" {
  name        = "openhab_access"
  description = "Access to S3 for openhab processes"
  policy = jsonencode(
    {
      Statement = [
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::mjmm-website-backups",
        ]
        Sid      = "listbackups"
      },
      {
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::mjmm-website-backups/*",
        ]
        Sid      = "writebackups"
      },
      ]
    Version   = "2012-10-17"      
    }
  )
  tags = {
    "billingtag" = "openhab"
  }
}

resource "aws_iam_user_policy_attachment" "oh_user_attach" {
  user       = aws_iam_user.openhab_user.name
  policy_arn = aws_iam_policy.openhab_user_policy.arn
}

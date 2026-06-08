# Copyright (C) 2018- Mark McIntyre

# Terraform for the IAM roles

##############################################################################################
# __generated__ by Terraform from "S3FullAccess"
resource "aws_iam_role" "S3FullAccess" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = "Allows EC2 instances to connect to S3"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "S3FullAccess"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags = {
    billingtag = "Management"
  }
}

# __generated__ by Terraform from "S3FullAccess"
resource "aws_iam_instance_profile" "S3FullAccess" {
  name        = "S3FullAccess"
  name_prefix = null
  path        = "/"
  role        = aws_iam_role.S3FullAccess.id
  tags        = {billingtag = "Management"}
}

# __generated__ by Terraform from "S3FullAccess/arn:aws:iam::aws:policy/AmazonS3FullAccess"
resource "aws_iam_role_policy_attachment" "aws-managed-policy-attachment1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.S3FullAccess.id
}

# __generated__ by Terraform from "S3FullAccess/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
resource "aws_iam_role_policy_attachment" "aws-managed-policy-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.S3FullAccess.id
}

# __generated__ by Terraform from "S3FullAccess/arn:aws:iam::317976261112:policy/PolForS3FullAccess"
resource "aws_iam_role_policy_attachment" "polatt4s3fullaccess" {
  policy_arn = aws_iam_policy.pol4s3fullaccess.arn # "arn:aws:iam::317976261112:policy/PolForS3FullAccess"
  role       = aws_iam_role.S3FullAccess.id
}

# __generated__ by Terraform from "arn:aws:iam::317976261112:policy/PolForS3FullAccess"
resource "aws_iam_policy" "pol4s3fullaccess" {
  description = null
  name        = "PolForS3FullAccess"
  name_prefix = null
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["logs:FilterLogEvents", "logs:GetLogEvents", "ec2:DescribeInstances", "ec2:StartInstances", "ec2:StopInstances", "ecs:DescribeClusters", "ecs:DescribeTasks", "ecs:RunTask", "s3:*"]
      Effect   = "Allow"
      Resource = ["*"]
      }, {
      Action   = ["iam:GetCredentialReport", "iam:GenerateCredentialReport"]
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
  tags = {
    billingtag = "Management"
  }
}

##############################################################################################

# __generated__ by Terraform from "lambda-s3-full-access-role"
resource "aws_iam_role" "lambda-s3-full-access-role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = "Allows lambda acccess to S3 buckets"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "lambda-s3-full-access-role"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}

# __generated__ by Terraform from "lambda-s3-full-access-role:assumeRolePol"
resource "aws_iam_role_policy" "stsAssumeLambda" {
  name        = "assumeRolePol"
  name_prefix = null
  policy = jsonencode({
    Statement = {
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = "arn:aws:iam::183798037734:role/s3AccessForRadio"
    }
    Version = "2012-10-17"
  })
  role = aws_iam_role.lambda-s3-full-access-role.id
}

# __generated__ by Terraform from "lambda-s3-full-access-role/arn:aws:iam::aws:policy/AmazonS3FullAccess"
resource "aws_iam_role_policy_attachment" "aws_managed_policy_l1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.lambda-s3-full-access-role.id
}

# __generated__ by Terraform from "lambda-s3-full-access-role/arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
resource "aws_iam_role_policy_attachment" "aws_managed_policy_l2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role = aws_iam_role.lambda-s3-full-access-role.id
}

# __generated__ by Terraform from "lambda-s3-full-access-role/arn:aws:iam::aws:policy/AWSLambdaFullAccess"
resource "aws_iam_role_policy_attachment" "aws_managed_policy_l3" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  role = aws_iam_role.lambda-s3-full-access-role.id
}

# __generated__ by Terraform from "lambda-s3-full-access-role/arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
resource "aws_iam_role_policy_attachment" "aws_managed_policy_l4" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role = aws_iam_role.lambda-s3-full-access-role.id
}

# __generated__ by Terraform from "lambda-s3-full-access-role:policygen-lambda-s3-full-access-role-201711082329"
resource "aws_iam_role_policy" "lambda_inline_policy_1" {
  name        = "policygen-lambda-s3-full-access-role-201711082329"
  name_prefix = null
  policy = jsonencode({
    Statement = [{
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Effect   = "Allow"
      Resource = ["*"]
      Sid      = "Stmt1510183751000"
    }]
    Version = "2012-10-17"
  })
  role = aws_iam_role.lambda-s3-full-access-role.id
}

##############################################################################################

# __generated__ by Terraform from "AWSServiceRoleForCloudWatchEvents/arn:aws:iam::aws:policy/aws-service-role/CloudWatchEventsServiceRolePolicy"
resource "aws_iam_role_policy_attachment" "cweventspolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/CloudWatchEventsServiceRolePolicy"
  role       = "AWSServiceRoleForCloudWatchEvents"
}

# __generated__ by Terraform from "arn:aws:iam::317976261112:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents"
resource "aws_iam_service_linked_role" "cweventslrole" {
  aws_service_name = "events.amazonaws.com"
  custom_suffix    = null
  description      = "Allows Cloudwatch Events to manage servers"
  tags             = {billingtag = "Management"}
}

##############################################################################################

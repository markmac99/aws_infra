# Copyright (C) 2018- Mark McIntyre

# Terraform to create KMS keys

# __generated__ by Terraform
resource "aws_kms_key" "container_key" {
  bypass_policy_lockout_safety_check = null
  custom_key_store_id                = null
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = null
  description                        = "My KMS Key"
  enable_key_rotation                = false
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy = jsonencode({
    Id = "key-default-1"
    Statement = [{
      Action = "kms:*"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::317976261112:root"
      }
      Resource = "*"
      Sid      = "Enable IAM User Permissions"
    }]
    Version = "2012-10-17"
  })
  region                  = var.region #"eu-west-2"
  #rotation_period_in_days = 2560
  tags = {
    billingtag = "Management"
  }
  tags_all = {
    billingtag = "Management"
  }
  xks_key_id = null
}

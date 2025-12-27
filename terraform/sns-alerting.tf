# Copyright (C) Mark McIntyre
# SNS topics etc for alerting

resource "aws_sns_topic" "myalerts" {
  name = "emailAlertingTopic"
  tags = {
    billingtag="MarksWebsite"
  }
}

resource "aws_sns_topic_subscription" "snsemailsubs" {
  topic_arn = aws_sns_topic.myalerts.arn
  protocol  = "email"
  endpoint  = "markmcintyre99@googlemail.com"
}

resource "aws_sns_topic" "s3activity" {
  name = "S3Activity"
  display_name                             = "S3Activity"
  tags = {
    billingtag="Management"
  }
}

resource "aws_sns_topic" "ebsactivity" {
  name = "EBSActivit"
  display_name = "DiskspaceMonitoring"
  tags = {
    billingtag="Management"
  }
}

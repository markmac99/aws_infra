data "aws_lambda_function" "createcamindexes" {
  function_name = "createCamIndexes"
}

resource "aws_s3_bucket_notification" "mjmm_notification_evts" {
  bucket = aws_s3_bucket.mjmm-data.id
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.createcamindexes.arn
    id                  = "ukxxxx_jpgs"
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "UK"
    filter_suffix = ".jpg"
  }
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.createcamindexes.arn
    id                  = "ukxxxx_mp4s"
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "UK"
    filter_suffix = ".mp4"
  }
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.createcamindexes.arn
    id                  = "allsky_startrails"
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "allsky/startrails"
    filter_suffix = ".jpg"
  }
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.createcamindexes.arn
    id                  = "allsky_keograms"
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "allsky/keograms"
    filter_suffix = ".jpg"
  }
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.createcamindexes.arn
    id                  = "allsky_mp4s"
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "allsky/videos"
    filter_suffix = ".mp4"
  }
}



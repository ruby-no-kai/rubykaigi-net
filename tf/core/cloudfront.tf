resource "aws_cloudwatch_log_delivery_destination" "rk-aws-logs-parquet-use1" {
  region = "us-east-1"

  name          = "rk-aws-logs"
  output_format = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = "${aws_s3_bucket.rk-aws-logs.arn}/vended/use1"
  }
}

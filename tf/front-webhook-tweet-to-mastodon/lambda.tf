locals {
  env_vars = {
    SQS_QUEUE_URL  = aws_sqs_queue.inbox.url
    SECRET_ARN     = aws_secretsmanager_secret.secret.arn
    DYNAMODB_TABLE = aws_dynamodb_table.table.name
    RACK_ENV       = "production"
  }
}

resource "aws_sqs_queue" "inbox" {
  name = "front-webhook-tweet-to-mastodon_prd_inbox"

  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "inbox-dlq" {
  name = "front-webhook-tweet-to-mastodon_prd_inbox-dlq"

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.inbox.arn]
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue_redrive_policy" "inbox" {
  queue_url = aws_sqs_queue.inbox.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inbox-dlq.arn
    maxReceiveCount     = 6
  })
}

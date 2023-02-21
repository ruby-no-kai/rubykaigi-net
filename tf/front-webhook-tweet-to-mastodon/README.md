# front-webhook-tweet-to-mastodon

## How it works

1. Outbound messages from Front to Twitter trigger [the webhook rule](https://app.frontapp.com/settings/tim:175685/rules/edit/3727497)
2. `inbound` function receives a webhook via Function URL and validates signature, then enqueues to `inbox` SQS queue
   - https://dev.frontapp.com/docs/webhooks-1
3. `outbound` function processes a `inbox` SQS message and posts a tweet to Mastodon account
   - Threading (`in_reply_to_id`) is preserved using DynamoDB; Stores map of Tweet ID : Mastodon Status ID
   - Reply to other users (non-threading replies) will be ignored
   - De-duplication is done using DynamoDB and Front's event ID.

## Configuration

Front Webhook Secret and Mastodon Bearer Token are manually stored to Secrets Manager.

https://us-west-2.console.aws.amazon.com/secretsmanager/secret?name=front-webhook-tweet-to-mastodon%2Fprd%2Fsecret&region=us-west-2

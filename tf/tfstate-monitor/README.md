# tfstate-monitor

Monitor number of resources and its daily cost in every tfstate exists in s3://rk-infra.

## Dashboard

https://rubykaigi.net/tfstate-monitor

## Trigger

- Everyday (via EventBridge Scheduler and Step Functions)
- When tfstate is updated (via EventBridge and Step Functions)

# amc - AWS Management Console Access behind ALB OIDC authentication

## Caveats

- User authentication is done through ALB's authenticate-oidc, however it doesn't give us a ID token, we have to generate JWT for sts:AssumeRoleWithWebIdentity and corresponding OpenID Connect Discovery Document...
  - We can't use sts:AssumeRole due to role chaining restriction on maximum session duration.

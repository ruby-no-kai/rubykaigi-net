# amc - AWS Management Console Access behind ALB OIDC authentication

A lambda function as a ALB target that serves a web application to obtain AWS credentials. While authentication is done via ALB OIDC integration, it also acts as OIDC IdP against AWS STS (read caveats).

## Secrets Rotation

AMC has a secret of RSA private key that used for ID token signing. Generation and periodic rotation are done through Secrets Manager and key rotation lambda function.

## Caveats

- User authentication is done through ALB's authenticate-oidc, however it doesn't give us a ID token, we have to generate JWT for sts:AssumeRoleWithWebIdentity and corresponding OpenID Connect Discovery Document...
  - We can't use sts:AssumeRole due to role chaining restriction on maximum session duration.

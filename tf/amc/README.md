# amc - AWS Management Console Access through Himari

https://amc.rubykaigi.net

Amc is an Sinatra app run on Lambda Function URL, which authenticates with Himari (idp.rubykaigi.org) and allow authenticated users to sign into AWS or generate credentials for AWS.

Amc uses its own signing key to use sts:AssumeRoleWithWebIdentity with appropriate `sub` claim and is auto-rotated through Secrets Manager.

For roles claim rule, refer to [tf/himari/config.ru](https://github.com/ruby-no-kai/rubykaigi-nw/blob/master/tf/himari/config.ru).

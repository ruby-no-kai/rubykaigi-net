# sts-cat - OIDC to GitHub token exchange

https://yrlrly5nve2l23wqbwumadvi4i0wchbp.lambda-url.ap-northeast-1.on.aws/

Deployment of https://github.com/sorah/sts-cat

----

sts-cat exchanges an OIDC ID token for a GitHub App installation token, scoped by a trust policy stored in the target repository.

- Audience (`STS_CAT_IDENTIFIER`): `https://sts-cat.rubykaigi.net`. This is just an identifier, so call the function URL above.
- Allowed orgs: `ruby-no-kai`
- Allowed issuers: GitHub Actions (`https://token.actions.githubusercontent.com`), and this AWS account's outbound web identity federation issuer (`aws iam get-outbound-web-identity-federation-info`, enabled in [tf/core](../core/iam_outbound_web_identity_federation.tf))

## Trust policies

Place `.github/sts-cat/<identity>.sts.toml` in the target repository, or in `ruby-no-kai/.github` for org-level policies. The GitHub App must be installed on the repository with the requested permissions.

```toml
issuer = "https://token.actions.githubusercontent.com"
subject = "repo:ruby-no-kai/myrepo:ref:refs/heads/main"

[permissions]
contents = "read"
```

See [sts-cat README](https://github.com/sorah/sts-cat#trust-policies) for the full reference.

## Usage

### GitHub Actions

```yaml
permissions:
  id-token: write
steps:
  - uses: sorah/sts-cat/.github/actions/exchange-token@<sha>
    id: sts-cat
    with:
      endpoint: https://yrlrly5nve2l23wqbwumadvi4i0wchbp.lambda-url.ap-northeast-1.on.aws
      audience: https://sts-cat.rubykaigi.net
      scope: ruby-no-kai/myrepo
      identity: deploy
  - run: gh api repos/ruby-no-kai/myrepo
    env:
      GITHUB_TOKEN: ${{ steps.sts-cat.outputs.token }}
```

`audience` must be given explicitly as it differs from `endpoint`.

### AWS (sts:GetWebIdentityToken)

```sh
jwt=$(aws sts get-web-identity-token --audience https://sts-cat.rubykaigi.net --signing-algorithm RS256 --query WebIdentityToken --output text)
curl -X POST https://yrlrly5nve2l23wqbwumadvi4i0wchbp.lambda-url.ap-northeast-1.on.aws/token \
  -H "Authorization: Bearer ${jwt}" \
  -H "Content-Type: application/json" \
  -d '{"scope": "ruby-no-kai/myrepo", "identity": "deploy"}'
```

## Deploy

The GitHub App private key lives in KMS (`alias/sts-cat`), imported once with sts-cat's `contrib/aws-kms-import-pem.rb`:

```sh
KEY_ARN=$(aws kms describe-key --key-id alias/sts-cat --query KeyMetadata.Arn --output text --region ap-northeast-1)
AWS_REGION=ap-northeast-1 ruby path/to/sts-cat/contrib/aws-kms-import-pem.rb "$KEY_ARN" app.private-key.pem
```

To upgrade, bump the module `?ref=` together with `source_url` and `source_sha512` in [lambda.tf](./lambda.tf). Both values are in the [release](https://github.com/sorah/sts-cat/releases) description.

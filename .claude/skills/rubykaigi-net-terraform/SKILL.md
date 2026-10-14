---
name: rubykaigi-net-terraform
description: Conventions and ready-to-copy boilerplate for Terraform in the rubykaigi-net repository (tf/*). Use this whenever creating a new tf/<project> directory, adding AWS resources (IAM roles, Lambda, ECR, security groups, Route 53 records, EC2, RDS), wiring something to the EKS cluster (IRSA, kubernetes/helm providers), or reviewing Terraform changes in this repo, even when the user just says "add a lambda for X" or "make an ECR repo for Y". Load it before exploring tf/ so the usual survey of sibling projects can be skipped. Pair with /sorah-guides:terraform for the generic style rules.
---

# rubykaigi-net Terraform

Every directory under `tf/` is an independent root module with its own state. There are no shared local modules; projects share data through `terraform_remote_state` and data-source lookups. The facts below are already surveyed from the existing projects, so start writing instead of re-reading sibling directories. Open a reference project (see the table at the end) only when a pattern is not covered here.

Generic style (snake_case, PascalCase IAM names, `aws_iam_policy_document`, trailing commas, aligned `=`) comes from `/sorah-guides:terraform`. This skill covers what is specific to this repo.

## Creating a new project

Create `tf/<project>/` with these three files, then add resource files named by concern (`iam.tf`, `iam_lambda.tf`, `ecr.tf`, `lambda.tf`, `s3.tf`, `sg.tf`, `vpc.tf`, `route53.tf`, `kubernetes.tf`, `locals.tf`, ...).

`aws.tf`:

```hcl
provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project   = "<project>"
      Component = "<component>"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "current" {}
```

- `Project`: use `rk26net` (the current year's network project, bump the year when the existing ones do) for conference-network components such as dns-cache, dhcp, radius, syslog, acmesmith. Standalone services use their own name as both `Project` and `Component` (e.g. `glazed`, `attendee-gate`, `config-backup`).
- Add an aliased provider (`alias = "use1"`, `region = "us-east-1"`, same tags) only for us-east-1-only resources such as ACM certificates for CloudFront.

`backend.tf` (new projects use S3 native locking, not the legacy `dynamodb_table = "rk-terraform"` seen in older projects):

```hcl
terraform {
  backend "s3" {
    bucket       = "rk-infra"
    region       = "ap-northeast-1"
    key          = "terraform/<project>.tfstate"
    use_lockfile = true
  }
}
```

State keys: network components use `terraform/nw-<project>.tfstate`, standalone services use `terraform/<project>.tfstate`. Put `terraform_remote_state` blocks in `backend.tf` too.

`versions.tf`:

```hcl
terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

List every provider actually used (`random`, `archive`, `external`, `null`, `kubernetes`, `helm`, ...) without version pins unless one is needed.

`.terraform.lock.hcl` is committed. `.terraform/` is gitignored.

## Running Terraform

Run `terraform fmt` freely. `init`, `plan` and `apply` need AWS credentials that the human holds, so leave them to the user unless asked, and tell them which directory to run in. Mention when a change will replace a resource.

## Shared lookups

Main VPC (ap-northeast-1) and subnets, selected by the `Tier` tag (`public`, `private`, `onpremises`):

```hcl
data "aws_vpc" "main" {
  id = "vpc-004eca6fe0bf3494d"
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}
```

For a single subnet use `data "aws_subnet" "main-private-c"` with an extra `availability-zone` filter (`ap-northeast-1c` / `ap-northeast-1d`). The us-west-2 VPC lives in `tf/vpc-usw2`.

Route 53 zones for `rubykaigi.net`, with both a public and a private (split-horizon) zone:

```hcl
data "aws_route53_zone" "rubykaigi-net_public" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_route53_zone" "rubykaigi-net_private" {
  name         = "rubykaigi.net."
  private_zone = true
}
```

Internal service names live in the private zone (e.g. `origin.resolver.rubykaigi.net` CNAME to an NLB, `ttl = 300`).

Shared bucket: `data "aws_s3_bucket" "rk-infra" { bucket = "rk-infra" }`.

## IAM

Every role gets the `NocAdminBase` permissions boundary, the same policy attached to the NocAdmin role (`tf/admin-iam`).

```hcl
data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "LambdaFoo" {
  name                 = "LambdaFoo"
  description          = "rubykaigi-net//tf/<project>"
  assume_role_policy   = data.aws_iam_policy_document.LambdaFoo-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "LambdaFoo-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "LambdaFoo" {
  role   = aws_iam_role.LambdaFoo.name
  name   = "LambdaFoo"
  policy = data.aws_iam_policy_document.LambdaFoo.json
}

resource "aws_iam_role_policy_attachment" "LambdaFoo-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaFoo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

- Role names are PascalCase, prefixed by who assumes them: `Lambda<Project>`, `States<Project>`, `Events<Project>` (EventBridge/Scheduler), `Gha<Purpose>` (GitHub Actions), `Net<Component>` or `Nw<Component>` for in-cluster workloads.
- The `description` is `rubykaigi-net//tf/<project>`.
- One file per principal when there are several: `iam_lambda.tf`, `iam_states.tf`, `iam_events.tf`.

## EKS cluster integration

The cluster is managed in `tf/k8s` (state `terraform/nw-k8s.tfstate`). Its outputs are `cluster_config` (`endpoint`, `ca_data`, `name`), `cluster_oidc_config` (`arn`, `condition`) and `node_security_group`.

`backend.tf` addition:

```hcl
data "terraform_remote_state" "k8s" {
  backend = "s3"
  config = {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-k8s.tfstate"
  }
}
```

`kubernetes.tf`:

```hcl
locals {
  cluster_config      = data.terraform_remote_state.k8s.outputs.cluster_config
  cluster_oidc_config = data.terraform_remote_state.k8s.outputs.cluster_oidc_config
}

provider "kubernetes" {
  host                   = local.cluster_config.endpoint
  cluster_ca_certificate = base64decode(local.cluster_config.ca_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--region", "ap-northeast-1", "--cluster-name", local.cluster_config.name]
    command     = "aws"
  }
}
```

`helm.tf` uses the same values with the object syntax `kubernetes = { ... exec = { ... } }` (helm provider v3).

IRSA trust policy for a ServiceAccount:

```hcl
data "aws_iam_policy_document" "NetFoo-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.cluster_oidc_config.arn]
    }
    condition {
      test     = "StringEquals"
      variable = local.cluster_oidc_config.condition
      values   = ["system:serviceaccount:default:foo"]
    }
  }
}
```

Kubernetes manifests for the workloads themselves live in `k8s/` and are generated with `./gen-k8s.rb`. Terraform only creates the AWS-side resources plus the occasional `kubernetes_secret_v1` or ConfigMap.

## Common resources

ECR repository with a lifecycle policy (name it after the image):

```hcl
resource "aws_ecr_repository" "foo" {
  name = "foo"
}

resource "aws_ecr_lifecycle_policy" "foo" {
  repository = aws_ecr_repository.foo.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 10
        description  = "expire old images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

Security groups use `name = "<component>"`, plus `description = "rubykaigi-net//tf/<project>"` or the component name. Set `vpc_id = data.aws_vpc.main.id`, and give the egress block both `cidr_blocks = ["0.0.0.0/0"]` and `ipv6_cidr_blocks = ["::/0"]`. The network is IPv6-first, so include IPv6 wherever there's an IPv4 rule.

Lambda:
- Ruby zip function: `data "archive_file"` over a `.rb` file in the project directory, `runtime = "ruby3.4"`, `architectures = ["arm64"]`, `source_code_hash` from the archive. Function URL helpers come from the `function-url-utils--ruby34-arm64` layer (`data "aws_lambda_layer_version"`, built by `tf/function-url-utils`).
- Container function: `package_type = "Image"`, with `image_uri` from the project's ECR repository and an image tag held in `locals` (see `tf/glazed`, `tf/attendee-gate`). The app source lives in https://github.com/ruby-no-kai/rubykaigi-net-apps.
- `function_name` is `<project>` or `<project>-<role>` in kebab-case.

Secrets and passwords: prefer write-only arguments with ephemeral values (`ephemeral "random_password"`, `aws_ssm_parameter` with `value_wo` / `value_wo_version`, `kubernetes_secret_v1` with `data_wo`), so the values stay out of state. SSM parameter names are path-style, e.g. `/<project>/prd/<name>`, `/rds/<cluster>/<user>`.

EC2: Ubuntu arm64 AMI via `data "aws_ami"` (owner `amazon`) with `lifecycle { ignore_changes = [ami] }`. user_data comes from Jsonnet that extends `tf/cloudconfig.base.libsonnet` (creates user `rk` and fetches `https://rubykaigi.net/authorized_keys`). Use `replace_triggered_by` on a `null_resource` keyed by the user_data. See `tf/wire`.

## Jsonnet from Terraform

`tf/jsonnet.rb` is an external-data program that renders Jsonnet (via jrsonnet or jsonnet):

```hcl
data "external" "foo" {
  program = ["${path.module}/../jsonnet.rb"]
  query = {
    path = "${path.module}/foo.jsonnet"
    args = jsonencode({ key = "value" }) # optional, passed as TLA `args`
  }
}

locals {
  foo = jsondecode(data.external.foo.result.json)
}
```

Helm values (`*.jsonnet` next to `*.tf` in `tf/prom`, `tf/k8s-cert-manager`) and cloud-config use this.

## Reference projects

Open one of these only when you need a pattern not shown above:

| Need | Look at |
|---|---|
| Lambda (container) + Step Functions + Scheduler | `tf/glazed`, `tf/attendee-gate`, `tf/tfstate-monitor` |
| Ruby zip Lambda with Function URL | `tf/config-backup`, `tf/function-url-utils` |
| In-cluster service behind an NLB, with private DNS | `tf/dns-cache`, `tf/radius`, `tf/tftp` |
| IRSA role + ECR for a k8s workload | `tf/acmesmith`, `tf/syslog` |
| RDS + provisioning + k8s secret | `tf/dhcp`, `tf/grafana` |
| Helm releases | `tf/prom`, `tf/k8s-cert-manager` |
| EC2 instance with cloud-init | `tf/wire`, `tf/acme-responder`, `tf/bastion` |
| CloudFront + S3 static site | `tf/dot-net`, `tf/rko-preview` |
| ALB with OIDC auth | `tf/ops-lb` |
| Base VPC, shared IAM, shared buckets | `tf/core` |

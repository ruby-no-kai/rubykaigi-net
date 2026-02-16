locals {
  commit        = "4b72af0325fa04734827cabd4a9e5bec3fba513c"
  architectures = ["amd64", "arm64"]
  runtimes      = ["ruby3.3", "ruby3.4"]
}

data "aws_s3_bucket" "rk-tftp" {
  bucket = "rk-tftp"
}

resource "aws_lambda_layer_version" "function-url-utils" {
  for_each = {
    for v in
    flatten([
      for arch in local.architectures : [
        for runtime in local.runtimes :
        {
          arch     = arch
          runtime  = runtime
          runtime2 = replace(runtime, ".", "")
        }
      ]
    ]) : "${v.arch} ${v.runtime}" => v
  }
  s3_bucket                = data.aws_s3_bucket.rk-tftp.bucket
  s3_key                   = "ro/lambda/function-url-utils/${local.commit}/${each.value.arch}-${each.value.runtime2}.zip"
  layer_name               = "function-url-utils--${each.value.runtime2}-${each.value.arch}"
  compatible_runtimes      = [each.value.runtime]
  compatible_architectures = [replace(each.value.arch, "amd64", "x86_64")]

  skip_destroy = true
}

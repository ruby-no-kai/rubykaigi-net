data "archive_file" "amc" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/amc.zip"

  depends_on = [
    null_resource.amc-bundle-install,
    null_resource.amc-tsc,
    null_resource.amc-revision,
  ]
}

locals {
  tsdgst   = sha256(join("", [for f in fileset("${path.module}/src", "public/**/*.ts") : filesha256("${path.module}/src/${f}")]))
  rbdgst   = sha256(join("", [for f in fileset("${path.module}/src", "*.rb") : filesha256("${path.module}/src/${f}")]))
  lockdgst = filesha256("${path.module}/src/Gemfile.lock")
}

resource "null_resource" "amc-bundle-install" {
  triggers = {
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && bundle config set path vendor/bundle && BUNDLE_DEPLOYMENT=1 RBENV_VERSION=2.7 bundle install"
  }
}
resource "null_resource" "amc-tsc" {
  triggers = {
    tsdgst = local.tsdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && tsc -b"
  }
}

resource "null_resource" "amc-revision" {
  triggers = {
    tsdgst   = local.tsdgst,
    rbdgst   = local.rbdgst,
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && echo 'unknown.${sha256("${local.tsdgst}${local.rbdgst}${local.lockdgst}")}' > REVISION"
  }
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/source.zip"

  depends_on = [
    null_resource.bundle-install,
    null_resource.revision,
  ]
}

locals {
  rbdgst   = sha256(join("", [for f in fileset("${path.module}/src", "public/**/*.rb") : filesha256("${path.module}/src/${f}")]))
  lockdgst = filesha256("${path.module}/src/Gemfile.lock")
}

resource "null_resource" "bundle-install" {
  triggers = {
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && bundle config set path vendor/bundle && BUNDLE_DEPLOYMENT=1 RBENV_VERSION=2.7 bundle install"
  }
}
resource "null_resource" "revision" {
  triggers = {
    rbdgst   = local.rbdgst,
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && echo 'unknown.${sha256("${local.rbdgst}${local.lockdgst}")}' > REVISION"
  }
}



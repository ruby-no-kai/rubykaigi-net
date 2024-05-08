resource "aws_s3_bucket" "dot-net" {
  bucket = "rubykaigi-dot-net"
}

resource "aws_s3_bucket_public_access_block" "dot-net" {
  bucket = aws_s3_bucket.dot-net.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "dot-net" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.dot-net.arn}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "dot-net" {
  bucket = aws_s3_bucket.dot-net.id
  policy = data.aws_iam_policy_document.dot-net.json

  depends_on = [aws_s3_bucket_public_access_block.dot-net]
}

resource "aws_s3_bucket_website_configuration" "dot-net" {
  bucket = aws_s3_bucket.dot-net.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.dot-net.id
  key           = "index.html"
  content       = "<a href='https://github.com/ruby-no-kai/rubykaigi-net/tree/master/tf/dot-net'>https://github.com/ruby-no-kai/rubykaigi-net/tree/master/tf/dot-net</a>\n"
  content_type  = "text/html"
  cache_control = "max-age=0"
}
resource "aws_s3_object" "error" {
  bucket        = aws_s3_bucket.dot-net.id
  key           = "error.html"
  content       = "Error\n"
  content_type  = "text/html"
  cache_control = "max-age=0"
}

resource "aws_s3_object" "drive" {
  bucket           = aws_s3_bucket.dot-net.id
  key              = "drive"
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://drive.google.com/drive/folders/1rD0AougwZ5ttN87DUpGMaIJUl-LDC4z8?usp=drive_link"
}

resource "aws_s3_object" "kanban" {
  bucket           = aws_s3_bucket.dot-net.id
  key              = "kanban"
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://github.com/orgs/ruby-no-kai/projects/6"
}

resource "aws_s3_object" "sheet" {
  for_each         = toset(["sheet", "sheets", "spreadsheet", "spreadsheets"])
  bucket           = aws_s3_bucket.dot-net.id
  key              = each.value
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://docs.google.com/spreadsheets/d/1pilZBGOs2SutEbymZSzt1QgyBzJVxRTLgZgcccUDauk/edit#gid=900835928"
}

resource "aws_s3_object" "assets" {
  bucket           = aws_s3_bucket.dot-net.id
  key              = "assets"
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://docs.google.com/spreadsheets/d/1u27Eoip0GkvMGRFlqIeH5UZoMCDoXeYDKQ0GOxe7OJ0/edit#gid=0"
}

resource "aws_s3_object" "ssh" {
  bucket           = aws_s3_bucket.dot-net.id
  key              = "ssh"
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://scrapbox.io/rknet/ssh_config"
}

resource "aws_s3_object" "aws" {
  bucket           = aws_s3_bucket.dot-net.id
  key              = "aws"
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://scrapbox.io/rknet/AWS"
}

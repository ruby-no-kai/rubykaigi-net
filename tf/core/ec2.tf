data "aws_key_pair" "default" {
  key_name = "sorah-mulberry-rsa"
}


data "aws_iam_policy_document" "trust-ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

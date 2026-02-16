resource "aws_lambda_function" "skopeo-copy" {
  function_name = "skopeo-copy"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.skopeo-copy.repository_url}:cebbe3519498750c57b7e29887b3005ded019752-arm64"
  architectures = ["arm64"]

  role = aws_iam_role.lambda.arn

  memory_size = 256
  timeout     = 300
}

resource "aws_lambda_function" "skopeo-copy-unrestricted" {
  function_name = "skopeo-copy-unrestricted"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.skopeo-copy.repository_url}:cebbe3519498750c57b7e29887b3005ded019752-arm64"
  architectures = ["arm64"]

  role = aws_iam_role.lambda-unrestricted.arn

  memory_size = 256
  timeout     = 300
}

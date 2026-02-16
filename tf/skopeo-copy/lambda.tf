resource "aws_lambda_function" "skopeo-copy" {
  function_name = "skopeo-copy"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.skopeo-copy.repository_url}:74f566cb8a666dfbf20bdbbdfed0df92065ab685-arm64"
  architectures = ["arm64"]

  role = aws_iam_role.lambda.arn

  memory_size = 256
  timeout     = 300
}

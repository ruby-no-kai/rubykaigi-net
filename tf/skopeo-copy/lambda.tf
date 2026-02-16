resource "aws_lambda_function" "skopeo-copy" {
  function_name = "skopeo-copy"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.skopeo-copy.repository_url}:a4e641f02deeaea0059dd99514a62b3c4877b4be-arm64"
  architectures = ["arm64"]

  role = aws_iam_role.lambda.arn

  memory_size = 256
  timeout     = 300
}

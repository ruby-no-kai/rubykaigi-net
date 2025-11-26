module "himari_image" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/image"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/image"

  repository_name  = "himari-lambda"
  source_image_tag = "5b9d6b9bba45eba74eac1f04e4c71bac3fbcbf29"
}

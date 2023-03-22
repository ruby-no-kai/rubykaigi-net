module "himari_image" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/image"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/image"

  repository_name  = "himari-lambda"
  source_image_tag = "0e16c76a58ee8a801760479ceec4e2b0dab0374f"
}

module "himari_image" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/image"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/image"

  repository_name  = "himari-lambda"
  source_image_tag = "6d20cbc1701f903a986aaebd43dd277ce19d7b28"
}

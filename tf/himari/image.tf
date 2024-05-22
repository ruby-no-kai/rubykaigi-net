module "himari_image" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/image"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/image"

  repository_name  = "himari-lambda"
  source_image_tag = "a2671c1a6fe9d9bb7f8db04e9cff03bef3427fda"
}

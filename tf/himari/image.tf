module "himari_image" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/image"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/image"

  repository_name  = "himari-lambda"
  source_image_tag = "811ba96a31f8c24899878ae591efad3132ac0823"
}

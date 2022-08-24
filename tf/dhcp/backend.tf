terraform {
  backend "s3" {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-dhcp.tfstate"
  }
}

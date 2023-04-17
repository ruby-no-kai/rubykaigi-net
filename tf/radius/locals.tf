locals {
  nlb_subnets = {
    main-private-c = data.aws_subnet.main-private-c,
    main-private-d = data.aws_subnet.main-private-d,
  }
}

resource "aws_iam_role" "ec2-default" {
  name               = "NwEc2Default"
  description        = "rubykaigi-nw aws_iam_role.ec2-default"
  assume_role_policy = data.aws_iam_policy_document.trust-ec2.json
}

resource "aws_iam_instance_profile" "ec2-default" {
  name = aws_iam_role.ec2-default.name
  role = aws_iam_role.ec2-default.name
}

resource "aws_iam_role_policy_attachment" "ec2-default-ssm" {
  role       = aws_iam_role.ec2-default.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

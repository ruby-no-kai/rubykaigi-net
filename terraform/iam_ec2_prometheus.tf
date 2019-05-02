resource "aws_iam_role" "ec2_prometheus" {
  name = "Ec2Prometheus"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_prometheus-ec2_sd" {
  role = "${aws_iam_role.ec2_prometheus.id}"
  name = "ec2-sd"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:DescribeInstances",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_prometheus" {
  name = "Ec2Prometheus"
  role = "${aws_iam_role.ec2_prometheus.name}"
}

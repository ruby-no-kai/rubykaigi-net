resource "aws_iam_role" "StreamingStaff" {
  name                 = "StreamingStaff"
  description          = "rubykaigi-nw:tf/admin-iam aws_iam_role.StreamingStaff"
  assume_role_policy   = data.aws_iam_policy_document.StreamingStaff-trust.json
  max_session_duration = 3600 * 12
}

data "aws_iam_policy_document" "StreamingStaff-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/amc.rubykaigi.net",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "amc.rubykaigi.net:sub"
      values   = ["${data.aws_caller_identity.current.account_id}:StreamingStaff:*"]
    }
  }
}

resource "aws_iam_role_policy" "StreamingStaff" {
  role   = aws_iam_role.StreamingStaff.name
  policy = data.aws_iam_policy_document.StreamingStaff.json
}

data "aws_iam_policy_document" "StreamingStaff" {
  statement {
    effect = "Allow"
    actions = [
      "ivs:BatchGetChannel",
      "ivs:BatchGetStreamKey",
      "ivs:CreateChannel",
      "ivs:GetChannel",
      "ivs:GetPlaybackKeyPair",
      "ivs:GetRecordingConfiguration",
      "ivs:GetStream",
      "ivs:GetStreamKey",
      "ivs:ListChannels",
      "ivs:ListPlaybackKeyPairs",
      "ivs:ListRecordingConfigurations",
      "ivs:ListStreamKeys",
      "ivs:ListStreams",
      "ivs:ListTagsForResource",
      "ivs:PutMetadata",
      "ivs:StopStream",
      "ivs:UpdateChannel",
      "medialive:BatchDelete",
      "medialive:BatchStart",
      "medialive:BatchStop",
      "medialive:BatchUpdateSchedule",
      "medialive:CreateChannel",
      "medialive:CreateInput",
      "medialive:CreateTags",
      "medialive:DeleteChannel",
      "medialive:DeleteInput",
      "medialive:DeleteMultiplex",
      "medialive:DeleteMultiplexProgram",
      "medialive:DeleteSchedule",
      "medialive:DeleteTags",
      "medialive:DescribeChannel",
      "medialive:DescribeInput",
      "medialive:DescribeInputDevice",
      "medialive:DescribeInputDeviceThumbnail",
      "medialive:DescribeInputSecurityGroup",
      "medialive:DescribeMultiplex",
      "medialive:DescribeMultiplexProgram",
      "medialive:DescribeOffering",
      "medialive:DescribeReservation",
      "medialive:DescribeSchedule",
      "medialive:ListChannels",
      "medialive:ListInputDeviceTransfers",
      "medialive:ListInputDevices",
      "medialive:ListInputSecurityGroups",
      "medialive:ListInputs",
      "medialive:ListMultiplexPrograms",
      "medialive:ListMultiplexes",
      "medialive:ListOfferings",
      "medialive:ListReservations",
      "medialive:ListTagsForResource",
      "medialive:StartChannel",
      "medialive:StopChannel",
      "medialive:UpdateChannel",
      "medialive:UpdateChannelClass",
      "medialive:UpdateInput",
    ]
    resources = ["*"]
  }

}

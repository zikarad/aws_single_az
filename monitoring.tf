data "aws_iam_policy" "cwlog-policy" {

  count = "${var.cw-install ? 1 : 0}"

  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2-cwlogs" {

  count = "${var.cw-install ? 1 : 0}"

  role        = "${data.aws_iam_role.iamr-ec2.name}"
  policy_arn  = "${data.aws_iam_policy.cwlog-policy.arn}"
}

resource "aws_cloudwatch_log_group" "cwlog" {

  count = "${var.cw-install ? 1 : 0}"

  name              = "${var.prefix}"
  retention_in_days = "${var.cwlog-retention}"

  tags {
    Name    = "${var.prefix}"
    project = "${var.prefix}"
    stage   = "${var.stage}"
  }
}

resource "aws_cloudwatch_log_stream" "cwlog-stream" {

  count = "${var.cw-install ? 1 : 0}"

  name           = "generic-log"
  log_group_name = "${aws_cloudwatch_log_group.cwlog.name}"
}

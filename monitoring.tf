data "aws_iam_policy" "cwlog-policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2-cwlogs" {
  role        = "${aws_iam_role.iamr-ec2.name}"
  policy_arn  = "${data.aws_iam_policy.cwlog-policy.arn}"
}

resource "aws_cloudwatch_log_group" "cwlog" {
  name   = "${var.prefix}"
  retention_in_days = "${var.cwlog-retention}"

  tags {
    Name  = "${var.prefix}"
    value = "${var.stage}"
  }
}

resource "aws_cloudwatch_log_stream" "cwlog-stream" {
  name = "generic-log"
  log_group_name = "${aws_cloudwatch_log_group.cwlog.name}"
}

resource "aws_cloudwatch_log_group" "cwlog" {
  name   = "${var.prefix}"
  retention_in_days = "${var.cwlog-retention}"

  tags {
    Name = "${var.prefix}"
    value = "${var.stage}"
  }
}

resource "aws_cloudwatch_log_stream" "cwlog-stream" {
  name = "generic-log"
  log_group_name = "${aws_cloudwatch_log_group.cwlog.name}"
}

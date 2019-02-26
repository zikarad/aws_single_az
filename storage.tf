data "template_file" "policy-tpl" {
  template = "${file("s3-policy.tpl")}"

  vars     = {
    resource = "${aws_s3_bucket.s3-bucket.arn}"
  }
}

resource "aws_iam_policy" "s3-policy" {
  name    = "s3-bucket-rw"
  path    = "/"
  description = "Policy for read/write operation on bucket dedicated to host"

  policy =  "${data.template_file.policy-tpl.rendered}"

}

resource "aws_iam_role_policy_attachment" "ec2-s3-single_bucket-attach" {
  role       = "${aws_iam_role.iamr-ec2.name}"
  policy_arn = "${aws_iam_policy.s3-policy.arn}"
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.s3-bucket-name}"

  acl    = "private"
  versioning {
    enabled = false
  }
}

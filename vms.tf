/* INCOMING DATA */
data "aws_route53_zone" "r53zone" {
  name         = "${var.route53zone}"
  private_zone = false
}

/* MANAGE RESOURCES */
resource "aws_key_pair" "sshkey-gen" {
  key_name   = "${var.sshkey_name}"
  public_key = "${file("${var.sshkey_path}")}"
}

resource "aws_iam_instance_profile" "s3-rw-single_bucket" {
  name = "ec2-s3-single_bucket"
  role = "${aws_iam_role.iamr-ec2.name}"
}

resource "aws_security_group" "sg-host" {
  name   = "ssh access"
  description = "Allow ssh access from any"
  vpc_id = "${aws_vpc.vpc-main.id}"

  ingress {
	description = "SSH from any"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    =  "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    =  "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-host"
  }
}

resource "aws_spot_instance_request" "vm-host" {
  count         = "${var.hostcount}"

  spot_price    = "${var.spot-price}"
  wait_for_fulfillment   = true

  ami           = "${var.ami}"
  instance_type = "${var.host-size}"

  root_block_device {
    volume_size = "${var.root-block-size}"
    delete_on_termination = true
  }

  subnet_id              = "${aws_subnet.sn-pub.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-host.id}"]
  key_name               = "${aws_key_pair.sshkey-gen.key_name}"
  associate_public_ip_address = true
  iam_instance_profile   = "${aws_iam_instance_profile.s3-rw-single_bucket.name}"

  tags {
    Name  = "host-${count.index+1}"
    stage = "${var.stage}"
  }
}

resource "aws_route53_record" "arecord-pub" {
  count   = "${var.hostcount}"
  zone_id = "${data.aws_route53_zone.r53zone.zone_id}"
  name    = "host-${count.index+1}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_spot_instance_request.vm-host.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "arecord-priv" {
  count   = "${var.hostcount}"
  zone_id = "${data.aws_route53_zone.r53zone.zone_id}"
  name    = "${element(aws_spot_instance_request.vm-host.*.private_dns, count.index)}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_spot_instance_request.vm-host.*.private_ip, count.index)}"]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name         = "${var.domain_name}."
  private_zone = "false"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_val" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

/* OUTPUT IP */
output "public_ip" {
	value = ["${aws_spot_instance_request.vm-host.*.public_ip}"]
}

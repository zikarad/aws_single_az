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

resource "aws_iam_role" "iamr-ec2" {
	name  = "ec2instance-${var.prefix}"
	assume_role_policy = <<POLICY
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
POLICY

}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-${var.prefix}"
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
    project = "${var.prefix}"
    creator = "Terraform"
    stage   = "${var.stage}"
  }
}

resource "aws_security_group" "sg-tcp-custom" {
  count = "${length(var.add_tcp_ports)}"

  name = "Custom TCP"
  description = "Additional TCP ports"

  ingress {
    description = "port-${var.add_tcp_ports[count.index]}"
    from_port   = "${var.add_tcp_ports[count.index]}"
    to_port     = "${var.add_tcp_ports[count.index]}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-tcp-custom-${var.add_tcp_ports[count.index]}"
    project = "${var.prefix}"
    creator = "Terraform"
    stage   = "${var.stage}"
  }
}

resource "aws_security_group" "sg-udp-custom" {
  count = "${length(var.add_udp_ports)}"

  name = "Custom UDP"
  description = "Additional UDP ports"

  ingress {
    description = "port-${var.add_udp_ports[count.index]}"
    from_port   = "${var.add_udp_ports[count.index]}"
    to_port     = "${var.add_udp_ports[count.index]}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-udp-custom-${var.add_udp_ports[count.index]}"
    project = "${var.prefix}"
    creator = "Terraform"
    stage   = "${var.stage}"
  }
}

resource "aws_spot_instance_request" "vm-host" {
  count         = "${var.hostcount}"

  spot_price    = "${var.spot-price}"
  wait_for_fulfillment   = true

  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "${var.host-size}"

  root_block_device {
    volume_size = "${var.root-block-size}"
    delete_on_termination = true
  }

  subnet_id              = "${aws_subnet.sn-pub.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-host.id}"]
  key_name               = "${aws_key_pair.sshkey-gen.key_name}"
  associate_public_ip_address = true
  iam_instance_profile   = "${aws_iam_instance_profile.ec2-profile.name}"

  tags {
    Name  = "${var.prefix}-${count.index+1}"
    project = "${var.prefix}"
    creator = "Terraform"
    stage = "${var.stage}"
  }
}

resource "aws_route53_record" "arecord-pub" {
  count   = "${var.hostcount}"
  zone_id = "${data.aws_route53_zone.r53zone.zone_id}"
  name    = "${var.prefix}-${count.index+1}"
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

#resource "aws_acm_certificate" "cert" {
#  domain_name       = "${var.domain_name}"
#  validation_method = "DNS"
#}

#resource "aws_route53_record" "cert_validation" {
#  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
#  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
#  zone_id = "${data.aws_route53_zone.r53zone.id}"
#  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
#  ttl     = 60
#}

#resource "aws_acm_certificate_validation" "cert_val" {
#  certificate_arn         = "${aws_acm_certificate.cert.arn}"
#  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
#}

/* OUTPUT IP */

output "dnsnames" {
	value = ["${aws_route53_record.arecord-pub.*.name}"]
}

output "public_ip" {
	value = ["${aws_spot_instance_request.vm-host.*.public_ip}"]
}

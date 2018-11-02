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
	description = "alt-HTTPS"
    from_port   = 6443
    to_port     = 6443
    protocol    =  "tcp"
    cidr_blocks = ["10.0.1.0/24"]
	}

  ingress {
	description = "kubelet-api"
    from_port   = 10250
    to_port     = 10250
    protocol    =  "tcp"
    cidr_blocks = ["10.0.1.0/24"]
	}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "sg-host"
  }
}

resource "aws_instance" "vm-host" {
	count = "${var.hostcount}"

	ami						= "${var.ami}"
	instance_type = "${var.host-size}"

	subnet_id			= "${aws_subnet.sn-pub.id}"
	vpc_security_group_ids = ["${aws_security_group.sg-host.id}"]
	key_name      = "${aws_key_pair.sshkey-gen.key_name}"
	associate_public_ip_address = true

	tags {
		Name  = "host-${count.index+1}"
		stage = "${var.stage}"
	}
}

resource "aws_route53_record" "arecord" {
	count = "${var.hostcount}"

	zone_id = "${data.aws_route53_zone.r53zone.zone_id}"
    name    = "host-${count.index+1}"
    type    = "A"
	ttl     = 300
	records = ["${element(aws_instance.vm-host.*.public_ip, count.index)}"]
}

/* OUTPUT IP */
output "public_ip" {
	value = ["${aws_instance.vm-host.*.public_ip}"]
}

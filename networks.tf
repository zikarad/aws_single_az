/* --- VPCs */
resource "aws_vpc" "vpc-main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support   = true

  tags {
    Name    = "${var.prefix}"
    stage   = "${var.stage}"
    creator = "Terraform"
  }
}

resource "aws_vpc_dhcp_options" "dhcpopts" {
  domain_name         = "${var.domain_name}"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcpopts-assoc" {
  vpc_id          = "${aws_vpc.vpc-main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcpopts.id}"
}

/* local ENDPOINTS */
resource "aws_vpc_endpoint" "vpce-s3" {
  vpc_id       = "${aws_vpc.vpc-main.id}"
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "vpcea-s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.vpce-s3.id}"
  route_table_id  = "${aws_route_table.rt-pub.id}"
}

/* NETWORKS */
resource "aws_subnet" "sn-pub" {
  count = 1
  vpc_id = "${aws_vpc.vpc-main.id}"

  cidr_block        = "${var.subnets[count.index]}"
  availability_zone = "${var.region}${var.zone}"

  tags {
    Name  = "${var.prefix}-public1"
    stage = "${var.stage}"
    creator = "Terraform"
  }
}

/* GATEWAYs */
resource "aws_internet_gateway" "igw-main" {
  vpc_id = "${aws_vpc.vpc-main.id}"

  tags {
    Name  = "igw-${var.prefix}"
    stage = "${var.stage}"
    creator = "Terraform"
  }
}

/* ROUTE TABLEs */
resource "aws_route_table" "rt-pub" {
  vpc_id = "${aws_vpc.vpc-main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-main.id}"
  }

  tags {
    Name = "${var.prefix}-custom"
    stage = "${var.stage}"
    creator = "Terraform"
  }
}

/* ROUTE TABLE ASSOCIATION */
resource "aws_route_table_association" "rta-pub" {
  subnet_id      = "${aws_subnet.sn-pub.id}"
  route_table_id = "${aws_route_table.rt-pub.id}"
}

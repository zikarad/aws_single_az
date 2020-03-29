variable "domain_name" { default = "radekzika.cloud" }

variable "prefix" { default = "single-az" }
variable "stage"  { default = "poc"}

variable "vpc_cidr" { default = "10.0.0.0/16"}

/* AWS */
variable "amis" {
  type = "map"
  default = {
  /* Custom AMIs distributed worldwide */
    "eu-central-1" = "ami-077c0308fba3bc548"
    "us-east-1" = "ami-080a4cc6f658ef9e4"
  }
}

variable "region" { default = "eu-central-1" }
variable "zone"   { default = "a" }

variable "sshkey_path"    {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "route53zone"    {}
variable "s3-bucket-name" {
  description = "Common bucket for the project"
  default     = "single-az-project"
}

/* !!! public open port !!! */

variable "add_tcp_ports" { default = [] }
variable "add_udp_ports" { default = [] }
variable "host-size"       { default = "t3.medium" }
variable "spot-price"      { default = "0.03" }
variable "root-block-size" { default = "10" }
variable "cwlog-retention" { default = "7" }

variable "hostcount"   { default = 1 }

variable "sshkey_name" { default = "aws_gen" }

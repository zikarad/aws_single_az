variable "domain_name" { default = "radekzika.cloud" }

variable "prefix" { default = "single-az" }
variable "stage"  { default = "poc"}

variable "subnets" {
    type = "list"
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

/* AWS */
variable "ami" {
  # EU-CENTRAL-1 => CentOS 7
  default = "ami-0a84197c3325910a9"
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

variable "host-size"       { default = "t3.medium" }
variable "spot-price"      { default = "0.03" }
variable "cwlog-retention" { default = "7" }

variable "hostcount"   { default = 1 }

variable "sshkey_name" { default = "aws_gen" }

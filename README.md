# aws_single_az
single az environment features:
- VPC with 1 public subnet, 1 private subnet in 1 AZ
- AMI in us-east-1 and eu-central-1
  created and distibuted by Packer
- S3 endpoint, role, profile
- conditionaly build: bucket, Cloudwatch
- variable count (def. 1) spot EC2 instances + public IP
- Route53 record, cert. val. record
- option to add tcp/udp open port
  e.g. for WireGuard access add 5744

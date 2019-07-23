# aws_single_az
single az environment features:
- VPC with 1 public subnet, 1 private subnet in 1 AZ
- AMI in us-east-1 and eu-central-1
- S3 endpoint, role, profile
- conditionaly build: bucket, Cloudwatch
- variable count (def. 1) spot EC2 instances + public IP
- AWS ACM certificate
- Route53 record, cert. val. record
- option to add tcp/udp open port

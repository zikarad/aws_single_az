# aws_single_az
single az environment features:
- VPC with 1 public subnet in 1 AZ
- custom AMIs in 'eu-central-1' and 'us-east-1'
- custom port (security group) can be defined - sg not assigned
- S3 endpoint, bucket, role, profile
- variable count (def. 1) spot EC2 instances + public IP
- AWS ACM certificate
- Route53 record, cert. val. record
- CloudWatch logging

# aws_single_az
single az environment features:
- VPC with 1 public subnet in 1 AZ
- custom AMIs in 'eu-central-1' and 'us-east-1'
- custom port (security group) can be defined - sg not assigned
- S3 endpoint, bucket, role, profile
- conditionaly build: bucket, Cloudwatch
- variable count (def. 1) spot EC2 instances + public IP
- conditionaly build: AWS ACM certificate, cert. val. record
- Route53 record(s)
- CloudWatch logging

{
  "Version": "2012-10-17",
  "Statement": {
	  "Sid": "access-to-S3",
		"Principal": "*",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
		],
    "Resource": [
      "${resource}",
      "${resource}/*"
		]
  }
}

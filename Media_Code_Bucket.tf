# Media S3 bucket (Media & Code)
resource "aws_s3_bucket" "elizabethfolzgroupmedia" {
  bucket = "elizabethfolzgroupmedia"
  force_destroy = true

  tags = {
    Name = "elizabethfolzgroupmedia"
  }
}
# Media S3 bucket policy update
resource "aws_s3_bucket_policy" "elizabethfolzgroupmediabp" {
  bucket = aws_s3_bucket.elizabethfolzgroupmedia.id
  policy = jsonencode({
    Id = "mediabucketpolicy"
    Statement = [
      {
        Action = ["s3:GetObject","s3:GetObjectVersion"]
        Effect = "Allow"   
        Principal = {
            "AWS" = "*"
        }
        Resource = "arn:aws:s3:::elizabethfolzgroupmedia/*"
        Sid      = "PublicReadGetObject"
      }
    ]
    Version = "2012-10-17"
  })
}

# Log for Media Bucket
resource "aws_s3_bucket" "elizabethfolzgroup_logs" {
  bucket        = "elizabethfolzgroup_logs"
  force_destroy = true
  tags = {
    Name = "elizabethfolzgroup_logs"
  }
}

# Media Bucket Log Policy Update
resource "aws_s3_bucket_policy" "elizabethfolzgrouplogsbp" {
  bucket = aws_s3_bucket.elizabethfolzgroup_logs.id
  policy = jsonencode({
    Id = "mediabucketlogspolicy"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Resource = "arn:aws:s3:::elizabethfolzgroup_logs/*"
        Sid      = "PublicReadGetObject"
      }
    ]
    Version = "2012-10-17"
  })
}

# Code S3 bucket 
resource "aws_s3_bucket" "elizabethfolzgroupcode" {
  bucket = "codebucket"

  tags = {
    Name = "elizabethfolzroupcode"
  }
}

resource "aws_s3_bucket_acl" "elizabethfolzgroupcode_acl" {
  bucket = aws_s3_bucket.elizabethfolzgroupcode.id
  acl    = "private"
}
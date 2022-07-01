# Media S3 bucket (Media & Code)
resource "aws_s3_bucket" "elizabethfolzgroupmedia" {
  bucket        = "elizabethfolzgroupmedia"
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
        Action = ["s3:GetObject", "s3:GetObjectVersion"]
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
resource "aws_s3_bucket" "elizabethfolzgroup-elblogs" {
  bucket        = "elizabethfolzgroup-elblogs"
  force_destroy = true
  tags = {
    Name = "elizabethfolzgroup-elblogs"
  }
}

# Media Bucket Log Policy Update
resource "aws_s3_bucket_policy" "elizabethfolzgrouplogsbp" {
  bucket = aws_s3_bucket.elizabethfolzgroup-elblogs.id
  policy = jsonencode({
    Id = "mediabucketlogspolicy"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Resource = "arn:aws:s3:::elizabethfolzgroup-elblogs/*"
        Sid      = "PublicReadGetObject"
      }
    ]
    Version = "2012-10-17"
  })
}

# Code S3 bucket 
resource "aws_s3_bucket" "efgroupcodebucket" {
  bucket = "efgroupcodebucket"

  tags = {
    Name = "efgroupcodebucket"
  }
}

resource "aws_s3_bucket_acl" "elizabethfolzgroup-code-acl" {
  bucket = aws_s3_bucket.efgroupcodebucket.id
  acl    = "private"
}
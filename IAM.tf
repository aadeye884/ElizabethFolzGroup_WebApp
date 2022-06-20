# IAM profile
resource "aws_iam_instance_profile" "EliabethFolzGroup_IAM_Profile" {
  name = "EliabethFolzGroup_IAM_Profile"
  role = aws_iam_role.EliabethFolzGroup_IAM_Role.name
}

# IAM Role
resource "aws_iam_role" "EliabethFolzGroup_IAM_Role" {
  name        = "EliabethFolzGroup_IAM_Role"
  description = "S3 Full Permission"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "EliabethFolzGroup_IAM_Role"
  }
}

# IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "EliabethFolzGroup_IAM_Policy" {
  role       = aws_iam_role.EliabethFolzGroup_IAM_Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
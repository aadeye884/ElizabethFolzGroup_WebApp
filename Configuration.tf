# Create an EC2 instance
resource "aws_instance" "test_ec2" {
  ami                         = "ami-0f095f89ae15be883"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.test_public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.test_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "test_ec2"
  }
}
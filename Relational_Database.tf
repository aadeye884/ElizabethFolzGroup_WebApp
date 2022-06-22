# DB Subnet group
resource "aws_db_subnet_group" "elizabethfolzgroup_db_sbg" {
  name       = "elizabethfolzgroup_db_sbg"
  subnet_ids = [aws_subnet.ElizabethFolzGroup_Private_SN1.id, aws_subnet.ElizabethFolzGroup_Private_SN2.id]

  tags = {
    Name = "elizabethfolzgroup_db_sbg"
  }
}

# Mysql Relational Database
resource "aws_db_instance" "elizabethfolzgroupdb" {
  allocated_storage      = 10
  identifier             = "elizabethfolzgroupdb"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  multi_az               = true
  db_name                = "elizabethfolzgroupdb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.elizabethfolzgroup_db_sbg.id
  vpc_security_group_ids = [aws_security_group.ElizabethFolzGroup_Backend_SG.id]
  publicly_accessible    = false
}
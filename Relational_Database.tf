# Create DB Subnet group
resource "aws_db_subnet_group" "ElizabethFolzGroup_DB_SBG" {
 name       = "elizabethfolzgroup_db_sbg"
 subnet_ids = [aws_subnet.ElizabethFolzGroup_Private_SN1.id, aws_subnet.ElizabethFolzGroup_Private_SN2.id]

 tags = {
   Name = "ElizabethFolzGroup_DB_SBG"
 }
}

# create RDS Mysql Database
resource "aws_db_instance" "ElizabethFolzGroup_DB" {
 allocated_storage      = 10
 identifier             = "elizabethfolzgroupdb"
 storage_type           = "gp2"
 engine                 = "mysql"
 engine_version         = "5.7"
 instance_class         = "db.t2.micro"
 multi_az               = true
 db_name                = "ElizabethFolzGroup_DB"
 username               = "admin"
 password               = "Admin123"
 parameter_group_name   = "default.mysql5.7"
 skip_final_snapshot    = true
 db_subnet_group_name   = aws_db_subnet_group.ElizabethFolzGroup_DB_SBG.id
 vpc_security_group_ids = [aws_security_group.ElizabethFolzGroup_Backend_SG.id]
 publicly_accessible    = false  
}
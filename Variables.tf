variable "public_key" {
  default     = "~/cloud_devops/ElizabthFolzGroup/ElizabethFolzGroup_WebApp/efg_key.pub"
  description = "path to my pub key"
}
variable "ami" {
  default = "ami-06640050dc3f556bb"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "instance_class" {
  default = "db.t2.micro"
}
variable "identifier" {
  default = "elizabethfolzgroupdb"
}
variable "key_name" {
  default = "efg_key"
}
variable "db_name" {
  default     = "elizabethfolzgroupdb"
  description = "Database name"
}
variable "db_username" {
  default     = "admin"
  description = "Database username"
}
variable "db_password" {
  default     = "Admin123"
  description = "Database password"
}
variable "Domain_name" {
  default = "www.elizabethfolzgroup.com"
}
variable "VPC_cidr_block" {
  default     = "10.0.0.0/16"
  description = "custom VPC cidr block"
}
variable "public_subnet1_cidr_block" {
  default     = "10.0.1.0/24"
  description = "public subnet1 cidr block"
}
variable "public_subnet1_availabilityzone" {
  default     = "us-east-1a"
  description = "public subnet1 availability zone"
}
variable "public_subnet2_cidr_block" {
  default     = "10.0.3.0/24"
  description = "public subnet2 cidr block"
}
variable "public_subnet2_availabilityzone" {
  default     = "us-east-1b"
  description = "public subnet2 availability zone"
}
variable "private_subnet1_cidr_block" {
  default     = "10.0.2.0/24"
  description = "private subnet1 cidr block"
}
variable "private_subnet1_availabilityzone" {
  default     = "us-east-1a"
  description = "private subnet1 availability zone"
}
variable "private_subnet2_cidr_block" {
  default     = "10.0.4.0/24"
  description = "private subnet2 cidr block"
}
variable "private_subnet2_availabilityzone" {
  default     = "us-east-1b"
  description = "private subnet2 availability zone"
}
variable "public_routetable_cidr_block" {
  default     = "0.0.0.0/0"
  description = "public route table cidr block"
}
variable "private_routetable_cidr_block" {
  default     = "0.0.0.0/0"
  description = "private route table cidr block"
}
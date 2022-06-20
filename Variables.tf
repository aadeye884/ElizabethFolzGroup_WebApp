variable "ami" {
  default = "ami-06640050dc3f556bb"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "instance_class" {
  default = "db.t2.micro"
}
variable "EFG_Key" {
  default     = "~/cloud_devops/ElizabthFolzGroup/ElizabethFolzGroup_WebApp/EFG_Key.pub"
  description = "path to my keypairs"
}
variable "key_name" {
  default = "EFG_Key"
}

variable "db_name" {
  default     = "elizabethfolzgroupdb"
  description = "Database name"
}

# variable "database_identifier" {
#   default = "elizabethfolzgroupdb"
# }

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

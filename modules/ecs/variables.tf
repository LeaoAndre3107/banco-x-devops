variable "project" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "dynamodb_table_name" { type = string }
variable "ami_id" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
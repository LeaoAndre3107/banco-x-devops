provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../modules/vpc"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

module "dynamodb" {
  source = "../modules/dynamodb"

  project     = var.project
  environment = var.environment
}

module "alb" {
  source = "../modules/alb"

  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "../modules/ecs"

  project               = var.project
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.alb.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  dynamodb_table_name   = module.dynamodb.table_name
  ami_id = var.ami_id
  instance_type = "t3.micro"
  }
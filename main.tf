
module "vpc" {
  source = "./modules/aws-vpc"
  vpc-name        = var.VPC-NAME
  vpc-cidr        = var.VPC-CIDR
  igw-name        = var.IGW-NAME
  public-cidr1    = var.PUBLIC-CIDR1
  public-subnet1  = var.PUBLIC-SUBNET1
 
  private-cidr1   = var.PRIVATE-CIDR1
  private-subnet1 = var.PRIVATE-SUBNET1
  private-cidr2   = var.PRIVATE-CIDR2
  private-subnet2 = var.PRIVATE-SUBNET2
  eip-name1       = var.EIP-NAME1
  ngw-name1        = var.NGW-NAME1
  public-rt-name1  = var.PUBLIC-RT-NAME1
  private-rt-name1 = var.PRIVATE-RT-NAME1
  private-rt-name2 = var.PRIVATE-RT-NAME2
}
module "security-group" {
  source = "./modules/security-group"
  vpc-name    = var.VPC-NAME
  db-sg-name  = var.DB-SG-NAME

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/aws-rds"
  sg-name              = var.SG-NAME
  private-subnet-name1 = var.PRIVATE-SUBNET1
  private-subnet-name2 = var.PRIVATE-SUBNET2
  db-sg-name           = var.DB-SG-NAME
  rds-username         = var.RDS-USERNAME
  rds-pwd              = var.RDS-PWD
  db-name              = var.DB-NAME
  rds-name             = var.RDS-NAME

  depends_on = [module.security-group]
}



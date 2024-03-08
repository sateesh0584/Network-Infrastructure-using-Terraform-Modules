# 8 Creating DB subnet group for RDS Instances
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.sg-name
  subnet_ids = [data.aws_subnet.private-subnet1.id, data.aws_subnet.private-subnet2.id]
}

resource "aws_db_instance" "default" {
  identifier            = var.db-name 
  allocated_storage    = 10
  db_name              = var.db-name
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.rds-username
  password             = var.rds-pwd
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [data.aws_security_group.db-sg.id]
  tags = {
    Name = var.rds-name
  }
}


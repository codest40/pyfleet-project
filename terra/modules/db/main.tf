# DB Security Group
resource "aws_security_group" "db_sg" {
  description = "Security group for PostgreSQL database"
  name   = "pyfleet-db-sg"
  vpc_id = var.vpc_id

  # Allow inbound Postgres traffic ONLY from App SG
  ingress {
    description     = "Postgres from app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  # Allow all outbound traffic (optional)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "pyfleet-db-sg" })
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "pyfleet-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "pyfleet-db-subnet-group" })
}

resource "aws_db_instance" "primary" {
  identifier             = "pyfleet-db-primary"
  allocated_storage      = var.db_allocated_storage
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = var.multi_az
  performance_insights_enabled = true
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Enable automated backups
  backup_retention_period = 7
  tags                    = merge(var.tags, { Role = "primary" })
}

resource "aws_db_instance" "replicas" {
  count                  = var.replica_count
  identifier             = "pyfleet-db-replica-${count.index + 1}"
  instance_class         = var.db_instance_class
  engine                 = "postgres"
  engine_version         = var.engine_version
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  replicate_source_db    = aws_db_instance.primary.arn
  performance_insights_enabled = true
  skip_final_snapshot    = true

  tags = merge(var.tags, { Role = "replica-${count.index + 1}" })
}


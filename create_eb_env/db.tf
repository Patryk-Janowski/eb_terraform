data "aws_db_cluster_snapshot" "initial_cluster_snapshot" {
  db_cluster_snapshot_identifier = "initial-db-for-vulpy"
  most_recent                    = true
}

resource "aws_rds_cluster" "aurora_cluster_eb" {
  vpc_security_group_ids        = [aws_security_group.allow_mysql.id]
  cluster_identifier            = "aurora-eb-public"
  engine                        = "aurora-mysql"
  db_subnet_group_name          = aws_db_subnet_group.aurora_subnet_group.name
  backup_retention_period       = 1
  master_username               = "admin"
  skip_final_snapshot           = true
  storage_encrypted             = true
  kms_key_id                    = aws_kms_key.eb_key.arn
  deletion_protection           = false
  engine_mode                   = "provisioned"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.eb_key.arn
  snapshot_identifier           = data.aws_db_cluster_snapshot.initial_cluster_snapshot.id

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "aurora_db_isnstance" {
  for_each            = local.db_subnets
  cluster_identifier  = aws_rds_cluster.aurora_cluster_eb.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora_cluster_eb.engine
  engine_version      = aws_rds_cluster.aurora_cluster_eb.engine_version
  publicly_accessible = true
  identifier          = replace("aurora-db-instance-${each.key}", "_", "-")
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "eb-subnet-group"
  subnet_ids = local.db_subnets_list
  tags = {
    Name = "eb-subnet-group"
  }
}

data "aws_secretsmanager_secret" "aurora_db_credentials" {
  arn = aws_rds_cluster.aurora_cluster_eb.master_user_secret[0].secret_arn
}


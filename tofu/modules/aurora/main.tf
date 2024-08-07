
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster

resource "aws_rds_cluster" "this" {
  availability_zones   = var.cluster_zones
  database_name        = var.database.name.db
  cluster_identifier   = "${var.symbol.prefix}-aurora-cluster"
  db_subnet_group_name = var.subnet_group_name
  #
  master_username = var.database.master_user.username
  master_password = var.database.master_user.password
  #
  db_cluster_parameter_group_name     = "default.aurora-postgresql15"
  engine                              = "aurora-postgresql"
  port                                = 3306
  storage_encrypted                   = false
  engine_version                      = "15.5"
  iam_database_authentication_enabled = false
  engine_mode                         = "provisioned"
  deletion_protection                 = false
  #
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
  #
  lifecycle {
    ignore_changes = [master_password, availability_zones, snapshot_identifier, global_cluster_identifier]
  }
  #
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 1
  # preferred_backup_window      = "13:20-13:50"
  # preferred_maintenance_window = "tue:07:50-tue:08:20"
  #
  enable_http_endpoint = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "this" {
  cluster_identifier = aws_rds_cluster.this.cluster_identifier
  identifier         = "${aws_rds_cluster.this.cluster_identifier}-instance"

  # name               = var.database.name
  #
  availability_zone    = var.instance_zone
  db_subnet_group_name = var.subnet_group_name
  #
  instance_class             = "db.serverless"
  engine                     = "aurora-postgresql"
  engine_version             = "15.5"
  auto_minor_version_upgrade = true
  publicly_accessible        = false
  #port                         = 3306
  monitoring_interval = 0
}

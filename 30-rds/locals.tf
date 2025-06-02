locals {
  resource_name = "mysql-${var.project_name}-${var.environment}"
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value # Here, we are storing the mysql_sg_id value which is queried from data block
  database_subnet_group_name = data.aws_ssm_parameter.database_subnet_group_name.value
}


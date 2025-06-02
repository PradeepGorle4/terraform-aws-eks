module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier =  local.resource_name #expense-dev

  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name     = "transactions" # AWS will create this schema automatically
  username = "root"
  port     = "3306"
  password = "ExpenseApp1"
  manage_master_user_password = false # We are managing the password ourselves
  vpc_security_group_ids = [local.mysql_sg_id]


  skip_final_snapshot = true # since this snpashot uses the vpc, if this is not skipped, we face issue while destroying the vpc

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = local.database_subnet_group_name

  # DB parameter group
  family = "mysql8.0"

  deletion_protection = false

  # DB option group
  major_engine_version = "8.0"

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
  
  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_route53_record" "rds" {
    zone_id = var.zone_id
    name = "${local.resource_name}.${var.domain_name}"
    type = "CNAME"
    ttl = 5
    records = [module.db.db_instance_address]
}
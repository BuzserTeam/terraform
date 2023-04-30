module "postgres" {
  source = "terraform-aws-modules/rds/aws"
  engine = "postgres"
  engine_version = "13.4"
  instance_class = "db.t2.micro"
  name = "my-postgres-db"
  username = "postgres"
  password = "password123"
  db_subnet_group_name = module.eks.default_db_subnet_group_name
  vpc_security_group_ids = [module.eks.cluster_security_group_id]
}

module "redis" {
  source = "terraform-aws-modules/redis/aws"
  engine_version = "6.x"
  instance_type = "cache.t2.micro"
  subnet_ids = module.eks.private_subnet_ids
  security_group_ids = [module.eks.cluster_security_group_id]
  name = "my-redis-cache"
}

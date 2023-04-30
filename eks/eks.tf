module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "buzser-vpc"

  cidr = var.vpc_cidr_block

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = [var.private_subnet_cidr_block]
  public_subnets  = [var.public_subnet_cidr_block]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_eks_cluster" "buzser" {
  name = "buzser-cluster"
  role_arn = aws_iam_role.my_eks_cluster.arn
  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

resource "aws_security_group_rule" "buzser_ingress_rule" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.buzser_sg.id
}

resource "aws_security_group_rule" "buzser_egress_rule" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.buzser_sg.id
}

resource "aws_security_group" "buzser_sg" {
  name_prefix = "my-cluster-"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "redis_sg" {
  name_prefix = "redis-sg-"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg"
  }
}

resource "aws_security_group" "postgres_sg" {
  name_prefix = "postgres-sg-"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-sg"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "15.0.0"
  
  cluster_name = "my-eks-cluster"
  subnets      = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
  vpc_id       = "vpc-01234567"
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  
  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.medium"
      asg_desired_capacity = 3
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t3.large"
      asg_desired_capacity = 2
    },
  ]
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}


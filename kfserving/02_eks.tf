data "aws_availability_zones" "available" {
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                 = "${var.cluster_name}-k8s-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}


resource "aws_iam_policy" "worker_alb_policy" {
  name        = "${var.cluster_name}-worker-alb-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("config/iam_policy.json")
}

resource "aws_iam_policy" "worker_ecr_policy" {
  name        = "${var.cluster_name}-worker-ecr-policy"
  description = "Worker policy for the loading ECR Images"

  policy = file("config/ecr_policy.json")
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.0.1"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"

  subnets                     = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  workers_additional_policies = [aws_iam_policy.worker_alb_policy.arn,
                                 aws_iam_policy.worker_ecr_policy.arn]


  map_users    = var.map_users
  map_roles    = var.map_roles
  map_accounts = var.map_accounts

  node_groups = {
    cpu = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
    # small = {
    #   desired_capacity = 1
    #   max_capacity     = 1
    #   min_capacity     = 1
    #   instance_types   = ["t3.small"]
    # }
  }


  write_kubeconfig       = true
  kubeconfig_output_path = "./"
  kubeconfig_name        = "kubeconfig_${var.cluster_name}"
  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = var.profile
  }
}
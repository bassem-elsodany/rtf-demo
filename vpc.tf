variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default = "development"
}
variable "cluster_name" {
  description = "RTF EKS cluster name"
  type = string
  default = "rtf-cluster-demo"
}


variable "cluster_iam_role_name" {
  description = "RTF EKS cluster role name"
  type = string
  default = "rtf-cluster-demo-role"
}

provider "aws" {
  region = var.region
  profile = var.profile
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = var.cluster_name
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "3.2.0"
  version = "3.7.0"

  name                 = "${var.cluster_name}-vpc"
  cidr                 = "10.10.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.10.64.0/20", "10.10.80.0/20","10.10.96.0/20"]
  public_subnets       = ["10.10.0.0/20", "10.10.16.0/20","10.10.32.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

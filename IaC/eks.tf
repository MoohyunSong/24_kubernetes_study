module "eks" {
  source = "terraform-aws-modules/eks/aws"

  name    = "${var.prefix}-k8s-cluster"
  kubernetes_version = "1.35"

  endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  addons = {
    coredns                = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
      before_compute = true
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    "karpenter.sh/discovery" = "${var.prefix}-k8s-cluster"
  }

  depends_on = [module.vpc]
}


module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = "${var.prefix}-eks-mng"
  cluster_name = module.eks.cluster_name
  kubernetes_version = "1.35"

  subnet_ids = module.vpc.public_subnets

  cluster_service_cidr = module.eks.cluster_service_cidr
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [module.eks.node_security_group_id]

  ami_type = "AL2023_x86_64_STANDARD"

  min_size = 2
  max_size = 2
  desired_size = 2

  instance_types = ["t3.medium"]
  capacity_type = "ON_DEMAND"

  tags = {
    "Name" = "${var.prefix}-eks-mng"
  }
}
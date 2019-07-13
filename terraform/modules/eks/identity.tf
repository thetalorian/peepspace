# Identity and credential management
# ----------------------------------

# Cluster Role
data "aws_iam_policy_document" "cluster_role" {
  statement {
    effect =  "Allow"

    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
    name = "${var.cluster-name}-cluster"
    assume_role_policy = "${data.aws_iam_policy_document.cluster_role.json}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = "${aws_iam_role.eks_cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = "${aws_iam_role.eks_cluster.name}"
}

# Worker Role
data "aws_iam_policy_document" "node_role" {
  statement {
    effect =  "Allow"

    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
    name = "${var.cluster-name}-node"
    assume_role_policy = "${data.aws_iam_policy_document.node_role.json}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = "${aws_iam_role.eks_node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = "${aws_iam_role.eks_node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = "${aws_iam_role.eks_node.name}"
}

resource "aws_iam_instance_profile" "eks_node" {
    name = "${var.cluster-name}"
    role = "${aws_iam_role.eks_node.name}"
}

# Independant role for Kubectl

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kubectl_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "eks_kubectl_role" {
  name               = "example-kubectl-access-role"
  assume_role_policy = "${data.aws_iam_policy_document.kubectl_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
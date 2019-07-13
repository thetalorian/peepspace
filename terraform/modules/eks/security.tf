# AWS Security Group creation
# ---------------------------

# Cluster
resource "aws_security_group" "eks_cluster" {
    name = "${var.cluster-name}-cluster"
    description = "Cluster communication with worker nodes"
    vpc_id = "${aws_vpc.eks.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cluster-name}"
    }

}

resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
    cidr_blocks = ["${var.wsip}/32"]
    description = "Allow workstation to communicate with the cluster API server"
    from_port = 443
    protocol = "tcp"
    security_group_id = "${aws_security_group.eks_cluster.id}"
    to_port = 443
    type = "ingress"
}

# Workers
resource "aws_security_group" "eks_node" {
    name = "${var.cluster-name}-node"
    description = "Security group for all nodes in the cluster"
    vpc_id = "${aws_vpc.eks.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = "${
        map(
            "Name", "${var.cluster-name}-node",
            "kubernetes.io/cluster/${var.cluster-name}", "owned",
        )
    }"
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
    description = "Allow nodes to communicate with each other"
    from_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.eks_node.id}"
    source_security_group_id = "${aws_security_group.eks_node.id}"
    to_port = 65535
    type = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
    description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port = 1025
    protocol = "tcp"
    security_group_id = "${aws_security_group.eks_node.id}"
    source_security_group_id = "${aws_security_group.eks_cluster.id}"
    to_port = 65535
    type = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
    description = "Allow pods to communicate with the cluster API Server"
    from_port = 443
    protocol = "tcp"
    security_group_id = "${aws_security_group.eks_cluster.id}"
    source_security_group_id = "${aws_security_group.eks_node.id}"
    to_port = 443
    type = "ingress"
}

# In-cluster authentication
data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${var.cluster-name}"
}

resource "kubernetes_config_map" "aws_auth_configmap" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }

    data = {
        mapRoles = <<YAML
- rolearn: ${aws_iam_role.eks_node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.eks_kubectl_role.arn}
  username: kubectl-access-user
  groups:
    - system:masters
YAML
    }
}
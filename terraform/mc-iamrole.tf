data "aws_iam_policy_document" "clusterrolepolicy" {
  statement {
    effect =  "Allow"

    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

output "clusterrole_role_policy" {
  value = "${data.aws_iam_policy_document.clusterrolepolicy.json}"
}

resource "aws_iam_role" "demo-cluster" {
    name = "terraform-eks-demo-cluster"
    assume_role_policy = "${data.aws_iam_policy_document.clusterrolepolicy.json}"
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = "${aws_iam_role.demo-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = "${aws_iam_role.demo-cluster.name}"
}

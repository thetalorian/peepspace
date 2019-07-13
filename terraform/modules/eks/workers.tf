data "aws_ami" "eks-worker" {
    filter {
        name = "name"
        values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
    }

    most_recent = true
    owners = ["602401143452"]
}

data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "eks" {
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.eks_node.name}"
    image_id = "${data.aws_ami.eks-worker.id}"
    instance_type = "m4.large"
    name_prefix = "${var.cluster-name}"
    security_groups = ["${aws_security_group.eks_node.id}"]
    user_data_base64 = "${base64encode(local.eks_node_userdata)}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "eks" {
    desired_capacity = 3
    launch_configuration = "${aws_launch_configuration.eks.id}"
    max_size = 5
    min_size = 1
    name = "${var.cluster-name}"
    vpc_zone_identifier = flatten(["${aws_subnet.eks.*.id}"])

    tag {
        key = "Name"
        value = "${var.cluster-name}"
        propagate_at_launch = true
    }

    tag {
        key = "kubernetes.io/cluster/${var.cluster-name}"
        value = "owned"
        propagate_at_launch = true
    }
}
# Networking setup for EKS
data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
  tags = "${
      map(
          "Name", "${var.cluster-name}-node",
          "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
  }"
}

resource "aws_subnet" "eks" {
    count = "${var.subnetcount}"

    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    cidr_block = "10.0.${count.index}.0/24"
    vpc_id = "${aws_vpc.eks.id}"
    tags = "${
        map(
            "Name", "${var.cluster-name}-node",
            "kubernetes.io/cluster/${var.cluster-name}", "shared",
        )
    }"
}

resource "aws_internet_gateway" "eks" {
    vpc_id = "${aws_vpc.eks.id}"
    tags = {
        Name = "${var.cluster-name}"
    }
}

resource "aws_route_table" "eks" {
    vpc_id = "${aws_vpc.eks.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.eks.id}"
    }
}

resource "aws_route_table_association" "eks" {
    count = "${var.subnetcount}"
    subnet_id = "${aws_subnet.eks.*.id[count.index]}"
    route_table_id = "${aws_route_table.eks.id}"
}

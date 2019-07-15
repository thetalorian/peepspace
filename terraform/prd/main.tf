module "eks" {
    source = "../modules/eks"
    cluster-name = "peepspace"
    subnetcount = "2"
    wsip = "12.25.175.47"
}

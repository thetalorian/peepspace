module "eks" {
    source = "../modules/eks"
    cluster-name = "peepspace"
    subnetcount = "2"
    wsip = "75.84.153.131"
}

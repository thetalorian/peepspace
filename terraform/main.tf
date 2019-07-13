module "atest" {
    source = "./modules/tester"
    sg_description = "lava"
}

module "atest2" {
    source = "./modules/tester"
    sg_description = "water"
}

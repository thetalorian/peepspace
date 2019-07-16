module "eks" {
    source = "../modules/eks"
    cluster-name = "peepspace"
    subnetcount = "2"
    wsip = "12.25.175.47"
}

module "sg" {
    description = "SPIKES!"
}

resource "aws_security_group" "tester" {
    name = "LAVA"
    description = "The floor is LAVA!!"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Tester"
    }

}

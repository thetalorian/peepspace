resource "aws_security_group" "test-cluster" {
    name = "tester ${var.sg_description}"
    description = "The floor is ${var.sg_description} !!"
    
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
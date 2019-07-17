resource "aws_security_group" "test-sg" {
    name = "tester ${var.description}"
    description = "The floor is ${var.description}!!"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Floor"
    }

}

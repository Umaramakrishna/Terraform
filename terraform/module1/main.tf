

module "server" {

    source = "./ec2_instance"

    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
    key_name = "Kalyankey"

}

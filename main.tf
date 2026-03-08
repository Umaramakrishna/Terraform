
provider "aws" {

  region = "us-east-1"

}


resource "aws_vpc" "prod_vpc" {

  cidr_block = "10.80.0.0/16"

  tags = {

    Name = "prod_vpc"
  }


}


resource "aws_internet_gateway" "prod_igw" {

  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod_igw"
  }

}

resource "aws_route_table" "prod_rt" {

  vpc_id = aws_vpc.prod_vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }
  tags = {
    Name = "prod_rt"
  }
}

resource "aws_subnet" "prod_sn" {

  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.80.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod_sn"
  }

}

resource "aws_route_table_association" "prod_rt_asso" {

  route_table_id = aws_route_table.prod_rt.id
  subnet_id      = aws_subnet.prod_sn.id

}


resource "aws_security_group" "prod_sg" {

  name        = "prod_web_sg"
  description = "allow SSH,HTTP and HTTPS protocols"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {

    Name = "prod_sg"
  }

}



resource "aws_instance" "prod_instance" {



  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t2.micro"
  key_name      = "Kalyankey"

  vpc_security_group_ids = [aws_security_group.prod_sg.id]
  subnet_id              = aws_subnet.prod_sn.id


  connection {

    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/kalyanbathini/Desktop/kalyanpasskey/Kalyankey.pem")
    host        = self.public_ip


  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo cp /tmp/index.html /var/www/html/index.html"
    ]

  }

  provisioner "local-exec" {
    command = "echo 'hello this kalyan file' > test.txt"
  }

  tags = {
    Name = "prod_ser"
  }

}





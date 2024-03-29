resource "aws_instance" "test_server" {
  ami           = "ami-09c443d9277298026"
  instance_type = "t4g.nano"
  key_name      = "test"
  vpc_security_group_ids = ["sg-0ede071b9326edb80"]

  tags = {
    Name = "Test-Server",
    Team = "pod1"
  }
}

resource "aws_instance" "test_server_usea1" {
  ami           = "ami-0a55ba1c20b74fc30"
  instance_type = "t4g.nano"
  key_name      = "test"
  vpc_security_group_ids = ["sg-0e777d45ce43491df"]

  tags = {
    Name = "Test-Server",
    Team = "pod1"
  }
  provider = aws.usea1 
}
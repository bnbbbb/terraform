resource "random_password" "password" {
  length = 16
  special = true
  override_special = "!#$%"
}

## 5.2.1
resource "local_file" "foo" {
  content = "foo"
  filename = "${path.module}/foo.txt"
}

# ### 5.3
# # AWS 프로바이더 선언 생략
# resource "aws_instance" "web" {
#   ami = "ami-0c55b159cbfafe1f0"
#   instance_type = "t3.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
  
# }

# resource "aws_instance" "web" {
#   count = "${terraform.workspace == "default" ? 5: 1}"
#   ami = "ami-0c55b159cbfafe1f0"
#   instance_type = "t3.micro"

#   tags = {
#     Name = "HelloWorld-${terraform.workspace}"
#   }
  
# }


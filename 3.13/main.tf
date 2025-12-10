# ### 3.13.1 null_resource 리소스
# resource "aws_instance" "foo" {
#     ami = "ami-0c55b159cbfafe1f0"
#     instance_type = "t3.micro"

#     private_ip = "10.0.0.12"
#     subnet_id = aws_subnet.tf_test_subnet.id

#     provisioner "remote-exec" {
#         inline = [
#             "echo ${aws_eip.bar.public_ip}"
#         ]
#     }
# }

# resource "aws_eip" "bar" {
#     instance = aws_instance.foo.id
#     associate_with_private_ip = "10.0.0.12"
#     depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_instance" "foo" {
#     ami = "ami-0c55b159cbfafe1f0"
#     instance_type = "t3.micro"

#     private_ip = "10.0.0.12"
#     subnet_id = aws_subnet.tf_test_subnet.id
# }

# resource "aws_eip" "bar" {
#     instance = aws_instance.foo.id
#     associate_with_private_ip = "10.0.0.12"
#     depends_on = [aws_internet_gateway.gw]
# }

# resource "null_resource" "foo" {
#     provisioner "remote-exec" {
#         connection {
#             host = aws_eip.bar.public_ip
#         }
#         inline = [
#             "echo ${aws_eip.bar.public_ip}"
#         ]
#     }
# }

# resource "null_resource" "foo" {
#     triggers = {
#         ec2_id = aws_instance.bar.id # instance의 id가 변경되는 경우 재실행
#     }
# #   ... 생략
# }

# resource "null_resource" "barz" {
#     triggers = {
#       ec2_id = time() # terraform 실행 계획을 생성할 때 마다 재실행
#     }
# #   ... 생략
# }

# resource "terraform_data" "foo" {
#     triggers_replace = [
#         aws_instance.bar.id,
#         aws_instance.barz.id
#     ]

#     input = "world"
# }
# output "terraform_data_output" {
#     value = terraform_data.foo.output # 출력 결과는 "world"
# }

### 3.14 moved 블록
# resource "local_file" "a" {
#     content = "foo!"
#     filename = "${path.module}/foo.bar"
  
# }

# output "file_content" {
#     value = local_file.a.content
# }
# resource "local_file" "b" {
#     content = "foo!"
#     filename = "${path.module}/foo.bar"
  
# }

# output "file_content" {
#     value = local_file.b.content
# }

variable "my_var" {}

resource "local_file" "b" {
    content = "foo!"
    filename = "${path.module}/foo.bar"
  
}
moved {
    from = local_file.a
    to = local_file.b
}

output "file_content" {
    value = local_file.b.content
}
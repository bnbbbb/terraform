# data "local_file" "abc" {
#     filename = "${path.module}/abc.txt"
# }

# # data "<리소스 유형>" "<이름>" {
# #     <인수> = <값>
# # }

# # # 데이터 소스 참조
# # data.<리소스 유형>.<이름>.<속성>


### AWS 프로바이더의 가용영역을 작업자가 수동으로 입력하지 않고 프로바이더로 접근한 환경에서 제공되는 데이터 소스를 활용해 subnet의 가용영역 인수를 정의하는 예시
# data "aws_availability_zones" "available" {
#     state = "available"
# }

# resource "aws_subnet" "primary" {
#     availability_zone = data.aws_availability_zones.available.names[0]
#     # e.g. ap-northeast-2a
# }

# resource "aws_subnet" "secondary" {
#     availability_zone = data.aws_availability_zones.available.names[1]
#     # e.g. ap-northeast-2b
# }

# resource "local_file" "abc" {
#   content  = "123!"
#   filename = "${path.module}/abc.txt"
# }

# data "local_file" "abc" {
#   filename = local_file.abc.filename
# }

# resource "local_file" "def" {
#   content  = data.local_file.abc.content
#   filename = "${path.module}/def.txt"
# }

### 3.6 입력 변수
# resource "local_file" "maybe" {
#     count = var.file_create ? 1 : 0
#     content = var.content
#     filename = "maybe.txt"
# }

# variable "file_create" {
#     type = bool
#     default = true
# }

# variable "content" {
#     description = "파일이 생성되는 경우에 내용이 비어있는지 확인합니다."
#     type = string

#     validation {
#         condition = var.file_create == true ? length(var.content) > 0 : true
#         error_message = "파일 내용이 비어있을 수 없습니다."
#     }
# }

### 3.6.4 변수 참조
# variable "my_password" {}

# resource "local_file" "abc" {
#     content = var.my_password
#     filename = "${path.module}/abc.txt"
# }

### 3.6.5 민감한 변수 취급
# variable "my_password" {
#     default = "password"
#     sensitive = true
# }

# resource "local_file" "abc" {
#     content = var.my_password
#     filename = "${path.module}/abc.txt"
# }

### 3.6.6 변수 입력 방식과 우선순위

# variable "my_var" {}
# variable "my_var" {
#     default = "var2"
# }

# resource "local_file" "abc" {
#     content = var.my_var
#     filename = "${path.module}/abc.txt"
# }

### 3.7 local
# variable "prefix" {
#     default = "hello"

# }

# locals {
#     name = "terraform"
#     content = "${var.prefix} ${local.name}"
#     my_info = {
#         age = 20
#         region = "KR"
#     }
#     my_nums = [1, 2, 3, 4, 5]
# }

# locals {
#     content = "content2" # 중복 선언 -> 오류
# }

### 3.7.2 local 참조
# variable "prefix" {
#     default = "hello"

# }

# locals {
#     name = "terraform"
# }

# resource "local_file" "abc" {
#     content = local.content
#     filename = "${path.module}/abc.txt"
# }

### 3.8 출력
# output "instance_ip_addr" {
#     value = "http://${aws_instance.web.private_ip}"
# }

# resource "local_file" "abc" {
#     content = "abc123"
#     filename = "${path.module}/abc.txt"
# }

# output "file_id" {
#     value = local_file.abc.id
# }

# output "file_abspath" {
#     value = abspath(local_file.abc.filename)
# }

### 3.9 반복문

# resource "local_file" "abc" {
#     count = 5
#     content = "abc"
#     filename = "${path.module}/abc.txt"
# }

### 3.9.1
# resource "local_file" "abc" {
#     count = 5
#     content = "abc"
#     filename = "${path.module}/abc${count.index}.txt"
# }

#  variable "names" {
#     type = list(string)
#     default = ["a", "b", "c"]
#  }

# resource "local_file" "abc" {
#     count = length(var.names)
#     content = "abc"
#     filename = "${path.module}/abc-${var.names[count.index]}.txt"
# }

# resource "local_file" "def" {
#     count = length(var.names)
#     content = local_file.abc[count.index].content
#     filename = "${path.module}/def-${element(var.names, count.index)}.txt"
# }

### 3.9.2 for_each
# resource "local_file" "abc" {
#     for_each = {
#         a = "content a"
#         b = "content b"

#     }
#     content = each.value
#     filename = "${path.module}/${each.key}.txt"
# }

# variable "names" {
#     default = {
#         a = "content a"
#         b = "content b"
#         c = "content c"
#     }
# }
# resource "local_file" "abc" {
#     for_each = var.names
#     content = each.value
#     filename = "${path.module}/abc-${each.key}.txt"
# }

# resource "local_file" "def" {
#     for_each = local_file.abc
#     content = each.value.content
#     filename = "${path.module}/def-${each.key}.txt"
# }

# variable "names" {
#     default = {
#         a = "content a"
#         c = "content c"
#     }
# }
# resource "local_file" "abc" {
#     for_each = var.names
#     content = each.value
#     filename = "${path.module}/abc-${each.key}.txt"
# }

# resource "local_file" "def" {
#     content = each.value.content
#     for_each = local_file.abc
#     filename = "${path.module}/def-${each.key}.txt"
# }
# resource "local_file" "abc" {
#     for_each = toset(["a", "b", "c"])
#     content = "abc"
#     filename = "${path.module}/abc-${each.key}.txt"
# }

# variable "names" {
#     default = ["a", "b", "c"]

# }

# # resource "local_file" "abc" {
# #     content = jsonencode(var.names)
# #     filename = "${path.module}/abc.txt"
# # }
# resource "local_file" "abc" {
#     content = jsonencode([for s in var.names : upper(s)])
#     filename = "${path.module}/abc.txt"
# }

# variable "names" {
#   type = list(string)
#   default = ["a", "b"]
# }

# output "A_upper_value" {
#     value = [for s in var.names : upper(s)]
# }

# output "B_index_and_value" {
#     value = [for i, v in var.names: "${i} => ${v}"]
# }

# output "C_make_objcet" {
#     value = {for s in var.names : s => upper(s)}
# }

# output "D_with_filter" {
#     value = [for v in var.names: upper(v) if v!= "a"]
# }

# variable "members" {
#     type = map(object({
#         role = string
#     }))
#     default = {
#         ab = {role = "member", group = "dev"}
#         cd = {role = "admin", group = "dev"}
#         ef = {role = "member", group = "obs"}
#     }
# }

# output "A_to_tuple" {
#     value = [for k, v in var.members : "${k} is ${v.role}"]
# }

# output "B_to_object" {
#     value = {
#         for name, user in var.members: name => user.role
#         if user.role == "admin"
#     }
# }

# output "C_group" {
#     value = {
#         for name, user in var.members: user.role => name...
#     }
# }

# resource "aws_security_group" "allow_tls" {
#     name = "allow_tls"
#     description = "Allow TLS inbound traffic"
#     ingress {
#         description = "TLS from VPC"
#         from_port = 443
#         to_port = 443
#         protocol = "tcp"
#         cidr_blocks = [aws_vpc.main.cibr_block]
#         ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#     }
#     ingress {
#         description = "HTTP"
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = [aws_vpc.main.cibr_block]
#         ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#     }
#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#         ipv6_cidr_blocks = ["::/0"]
#     }
#     tags = {
#         Name = "allow_tls"
#     }
# }

# # 일반적인 블록 속성 반복 적용
# resource "provider_resource" "name" {
#     name = "some_resource"

#     some_setting = {
#         key = a_value
#     }
#     some_setting = {
#         key = b_value
#     }
#     some_setting = {
#         key = c_value
#     }
#     some_setting = {
#         key = d_value
#     }
# }

# # dynamic 블록 적용
# resource "provider_resource" "name" {
#     name = "some_resource"

#     dynamic "some_setting" {
#         for_each = {
#             a_key = a_value
#             b_key = b_value
#             c_key = c_value
#             d_key = d_value
#         }
#         content {
#             key = some_setting.value
#         }
#     }
# }


# data "archive_file" "dotfiles" {
#     type = "zip"
#     output_path = "${path.module}/dotfiles.zip"
#     source {
#         content = "hello a"
#         filename = "${path.module}/a.txt"
#     }
#     source {
#         content = "hello b"
#         filename = "${path.module}/b.txt"
#     }
#     source {
#         content = "hello c"
#         filename = "${path.module}/c.txt"
#     }
# }

### 3.9.4 dynamic
# variable "names" {
#     default = {
#         a = "hello d"
#         b = "hello f"
#         c = "hello g"
#     }
# }

# data "archive_file" "dotfiles" {
#     type = "zip"
#     output_path = "${path.module}/dotfiles.zip"

#     dynamic "source" {
#         for_each = var.names
#         content {
#             content = source.value
#             filename = "${path.module}/${source.key}.txt"
#         }
#     }
# }

### 3.10 조건식

# variable "enable_file" {
#     default = true
# }

# resource "local_file" "foo" {
#     count = var.enable_file ? 4 : 0
#     content = "foo!"
#     filename = "${path.module}/foo.bar"
# }
# output "content" {
#     value = var.enable_file ? local_file.foo[0].content : "123"
# }

# resource "local_file" "foo" {
#     content = upper("foo!")
#     filename = "${path.module}/foo.bar"
# }

### 3.12.2 local_exec 프로비저너

# # Unix/Linux/MacOs
# resource "null_resource" "example1" {
#     provisioner "local-exec" {
#         command = <<EOF
#         echo Hello!! > file.txt
#         echo $ENV >> file.txt
#         EOF
#         interpreter = ["bash", "-c"]

#         working_dir = "/tmp"

#         environment = {
#             ENV = "world!"
#         }
#     }
# }

# # Windows
# resource "null_resource" "example2" {
#     provisioner "local-exec" {
#         command = <<EOF
#         Hello!! > file.txt
#         Get-ChildItem Env:ENV >> file.txt
#         EOF
#         interpreter = ["powershell", "-command"]
#         working_dir = "C:\\windows\\temp"
#         environment = {
#             ENV = "world!"
#         }
#     }
# }

# resource "null_resource" "example1" {
#     connection {
#         type = "ssh"
#         user = "root"
#         password = var.root_password
#         host = var.host
#     }

#     provisioner "file" {
#         source = "conf/myapp.conf"
#         destination = "/etc/myapp.conf"
#     }

#     provisioner "file" {
#         source = "conf/myapp.conf"
#         destination = "C:/App/myapp.conf"

#         connection {
#           type = "winrm"
#           user = "Administrator"
#           password = var.admin_password
#           host = var.host
#         }
#     }
# }

# resource "null_resource" "foo" {
#     # myapp.conf 파일이 /etc/myapp.conf 로 업로드
#     provisioner "file" {
#         source = "conf/myapp.conf"
#         destination = "/etc/myapp.conf"
#     }

#     #content의 내용이 /tmp/file.log 파일로 생성
#     provisioner "file" {
#         content = "ami used : ${self.ami}"
#         destination = "/tmp/file.log"
#     }

#     # configs.d 디렉토리가 /etc/configs.d 로 업로드
#     provisioner "file" {
#         source = "conf/configs.d/"
#         destination = "/etc"
#     }
#     # apps/app1 디렉토리 내의 파일들만 D:/IIS/webapp1 디렉토리 내에 업로드
#     provisioner "file" {
#         source = "apps/app1/"
#         destination = "D:/IIS/webapp1"
#     }
# }

# resource "aws_instance" "web" {
#     # ...

#     connection {
#         type = "ssh"
#         user = "root"
#         password = var.root_password
#         host = self.public_ip
#     }

#     provisioner "file" {
#         source = "script.sh"
#         destination = "/tmp/script.sh"
#     }

#     provisioner "remote-exec" {
#         inline = [
#             "chmod +x /tmp/script.sh",
#             "/tmp/script.sh args",
#         ]
#     }
# }
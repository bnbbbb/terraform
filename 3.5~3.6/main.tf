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

variable "members" {
    type = map(object({
        role = string
    }))
    default = {
        ab = {role = "member", group = "dev"}
        cd = {role = "admin", group = "dev"}
        ef = {role = "member", group = "obs"}
    }
}

output "A_to_tuple" {
    value = [for k, v in var.members : "${k} is ${v.role}"]
}

output "B_to_object" {
    value = {
        for name, user in var.members: name => user.role
        if user.role == "admin"
    }
}

output "C_group" {
    value = {
        for name, user in var.members: user.role => name...
    }
}
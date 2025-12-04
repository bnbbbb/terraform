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
variable "my_var" {
    default = "var2"
}

resource "local_file" "abc" {
    content = var.my_var
    filename = "${path.module}/abc.txt"
}
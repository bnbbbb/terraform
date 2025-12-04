# locals {
#   key1     = "value1"   # = 를 기준으로 키와 값이 구분
#   myStr    = "TF UTF-8" # UTF-8 문자를 지원
#   multiStr = <<EOF
# Multi
# Line
# String
# with anytext
# EOF
#   # Linux/macOS 에서는 EOF 같은 여러줄의 문자열을 지원

#   boolean1 = true  # boolean true
#   boolean2 = false # boolean false를 지원

#   decimal     = 123    # 기본적으로 숫자는 10진수
#   octal       = 0123   # 0으로 시작하는 숫자는 8진수
#   hexadecimal = "0xD5" # 0x 값을 포함하는 스트링은 16진수
#   scientific  = 1e10   # 과학 표기법도 지원


#   #function의 호출 예
#   myprojectname = format("%s is myproject name", var.project)

#   # 3항 연산자 조건문을 지원
#   credentials = var.credentials == "" ? file(var.credentials_file) : var.credentials

# }
# variable "project" {
#   type        = string
#   description = "project name"
# }

# variable "credentials" {
#   type    = string
#   default = ""
# }

# variable "credentials_file" {
#   type    = string
# }

# variable "credentials_file_file" {
#   type    = string
# }

# # terraform {
# #     required_version = "~> 1.8.0" # 테라폼 버전

# #     required_providers { # 프로바이더 버전을 나열
# #         random = {
# #             version = ">=3.0.0, < 3.6.0"
# #         }
# #         aws = {
# #             version = "~> 5.0"
# #         }
# #     }

# #     cloud { # HCP/Enterprise 같은 원격 실행을 위한 정보
# #         organization = "<MY_ORG_NAME>"

# #         workspaces {
# #           name = "my-first-workspace"
# #         }

# #     }
# #     backend "local" { # state를 보관하는 위치를 저장
# #         path = "relative/path/to/terraform.tfstate"
# #     }
# # }

# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "my-org"
#     workspaces {
#       name = "my-app-prod"
#     }
#   }
# }

# terraform {
#   cloud {
#     hostname = "app.terraform.io"
#     organization = "my-org"
#     workspaces {
#       name = "my-app-prod"
#     }
#   }
# }
# terraform {
#   required_version = ">= 1.0.0"
#   required_providers {
#     local = {
#       source  = "hashicorp/local"
#       version = ">= 2.0.0"
#     }
#   }

# }

# # terraform {
# #   backend "local" {
# #     path = "state/terraform.tfstate"
# #   }
# # }

# resource "local_file" "abc" {
#   content  = "abc!"
#   filename = "${path.module}/abc.txt"
# }

# resource "aws_instance" "web" {
#   ami = "ami-a1b2c3d4"
#   instance_type = "t3.micro"
# }

# # resource "local_file" "def" {
# #   content = "def!"
# #   filename = "${path.module}/def.txt"
# # }

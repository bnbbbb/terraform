provider "aws" {
    region = "ap-northeast-2"
}

module "ec2-seoul" {
    count = 2
    source = "../modules/terraform-aws-ec2"
}

output "module_output" {
    value = module.ec2-seoul[*].private_ip
}

locals {
    env = {
        dev = {
            type = "t2.micro"
            name = "dev_ec2"

        }
        prod = {
            type = "t2.micro"
            name = "prod_ec2"
        }
    }
}

module "ec2-seoul" {
    for_each = locals.env
    source = "../modules/terraform-aws-ec2"
    instance_type = each.value.type
    instance_name = each.value.name
}

output "module_output" {
    value = module.ec2-seoul[*].private_ip
}
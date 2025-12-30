### variable.tf ###

variable "instance_type" {
    default = "t2.micro"
    description = "vm 인스턴스 타입 정의"
}

variable "instance_name" {
    default = " my_ec2"
    description = "vm 인스턴스 이름 정의"
}


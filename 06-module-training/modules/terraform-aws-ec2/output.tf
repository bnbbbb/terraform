### output.tf ###

output "private_ip" {
    value = aws_instance.deafult.private_ip
}
### output.tf ###

output "id" {
    value = random_pet.name.id
}

output "password" {
    value = nonsensitive(random_password.password.result)
}
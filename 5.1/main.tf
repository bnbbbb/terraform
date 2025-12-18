# resource "random_password" "password" {
#   length = 16
#   special = true
#   override_special = "!#$%"
# }

### 5.2.1
# resource "local_file" "foo" {
#   content = "foo"
#   filename = "${path.module}/foo.txt"
# }
### 3.4.2 종속성
# resource "local_file" "abc" {
#   content  = "abc!"
#   filename = "${path.module}/abc.txt"
# }

# resource "local_file" "def" {
#   depends_on = [local_file.abc]
#   content  = "456"
#   filename = "${path.module}/def.txt"
# }

### 3.4.3 리소스 속성 참조

### 3.4.4 수명주기
# #### 3.4.4.1 create_before_destroy
# resource "local_file" "abc" {
#   content  = "lifecycle - step 2"
#   filename = "${path.module}/abc.txt"
#   lifecycle {
#     create_before_destroy = true
#   }
# }

#### 3.4.4.2 prevent_destroy
# resource "local_file" "abc" {
#   content  = "lifecycle - step 4" # 수정
#   filename = "${path.module}/abc.txt"
#   lifecycle {
#     prevent_destroy = true # 삭제 방지
#   }
# }

#### 3.4.4.3 ignore_changes
# resource "local_file" "abc" {
#   content  = "lifecycle - step 5" # 수정
#   filename = "${path.module}/abc.txt"
#   lifecycle {
#     ignore_changes = [] # 변경 무시
#   }
# }
# resource "local_file" "abc" {
#   content  = "lifecycle - step 4" # 수정
#   filename = "${path.module}/abc.txt"
#   lifecycle {
#     ignore_changes = [content] # 변경 무시
#   }
# }

#### 3.4.4.4 precondition

# variable "file_name" {
#   default = "step0.txt"
# }

# resource "local_file" "step6" {
#   content  = "lifecycle - step 6"
#   filename = "${path.module}/${var.file_name}"

#   lifecycle {
#     precondition {
#       condition     = var.file_name == "step6.txt"
#       error_message = "file_name is not \"step6.txt\""
#     }
#   }
# }

#### 3.4.4.5 postcondition
resource "local_file" "step7" {
  content = ""
  filename = "${path.module}/step7.txt"

  lifecycle {
    postcondition {
      condition = self.content != ""
      error_message = "content cannot empty"
    }
  }
}
output "step7_content" {
  value = local_file.step7.id
}
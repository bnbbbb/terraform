# ### 4.1.1
# #### 동일한 http 접두사를 사용하는 다수의 프로바이더 사용 정의
# terraform {
#   required_providers {
#     architect-http = {
#         source = "architect-team/http"
#         version = "~> 3.0"
#     }
#     http = {
#       source = "hashicorp/http"
#     }
#     aws-http = {
#         source = "terraform-aws-modules/http"
#     }
#  }
# }

# data "http" "example" {
#     provider = aws-http
#     url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

#     request_headers = {
#         Accept = "application/json"
#     }
# }

# ### 4.1.2
# provider "aws" {
#     region = "us-west-1"
# }

# provider "aws" {
#     alias = "seoul"
#     region = "ap-northeast-2"
# }

# resource "aws_instance" "app_server" {
#     provider = aws.seoul
#     ami = "ami-0c55b159cbfafe1f0"
#     instance_type = "t3.micro"
# }

# ### 4.1.3
# terraform {
#   required_providers {
#     <프로바이더 로컬 이름> =  {
#         source = [<호스트 수조>/]<네임스페이스>/<유형>
#         version = [<버전 제약>]
#     }
#   }
# }

### 4.3.1 AWS
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "ap-northeast-2"
  access_key = "<my-access-key>"
  secret_key = "<my-secret-key>"
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
resource "aws_instance" "app_server" {
  ami = data.aws.ami.amzn2.id
  instance_type = "t3.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
  
}



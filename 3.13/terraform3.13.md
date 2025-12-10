### 3.13 null_resource and terraform_data

> 기존 null_resource 리소스를 대체하는 terraform_data 리소스가 도입됨

#### 3.13.1 null_resource 리소스

> null_resource는 말 그대로 아무 작업도 수행하지 않는 리소스를 구현한다.

##### 필요성

- 테라폼 `프로비저닝` 동작을 설계하면서 사용자가 의도적으로 `프로비저닝`하는 동작을 조율해야 하는 상황이 발생하며, `프로바이더`가 제공하는 리소스 수명주기 관리만으로는 이를 해결하기 어렵기 때문에

##### 시나리오

- `프로비저닝` 수행 과정에서 명령어 실행
- `프로비저너`와 함께 사용
- 모듈, 반복문, 데이터 소스, 로컬 변수와 함께 사용
- 출력을 위한 데이터 가공

예를 들어,

- AWS EC2 인스턴스 `프로비저닝`하면서 웹서비스를 실행시키고 싶다.
- 웹서비스 설정에는 노출되어야 하는 고정된 외부 IP가 포함된 구성 필요. 따라서 aws_eip 리소스를 생성해야 한다.

AWS EC2 인스턴스를 `프로비저닝`하기 위해 aws_instance 리소스 구성 시 앞서 확인한 `프로비저너`를 활용하여 웹서비스를 실행하고자 한다면 다음과 같은 코드 구성이 작성된다.

```
resource "aws_instance" "foo" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t3.micro"

    private_ip = "10.0.0.12"
    subnet_id = "aws_subnet.tf_test_subnet.id"

    provisioner "remote-exec" {
        inline = [
            "echo ${aws_eip.bar_public_ip}"
        ]
    }
}

resource "aws_eip" "bar" {
    vpc = true

    instance = aws_instance.foo.id
    associate_with_private_ip = "10.0.0.12"
    depends_on = [aws_instance_gateway.gw]
}

```

- aws_eip가 생성하는 고정된 IP를 할당하기 위해서는 대상인 aws_instance의 id가 필요하다.
- aws_instance의 `프로비저너` 동작에서는 aws_eip가 생성하는 속성 값인 public_ip가 필요하다.

```
terraform plan
Error: Cycle: aws_eip.bar, aws_instance.foo
```

> 상호 참조되는 종속성을 끊기 위해서는 둘 중 하나의 실행 시점을 한 단계 뒤로 미뤄야한다.

> 이런 경우 실행에 간격을 추가하여 실제 리소스와는 무관한 동작을 수행하기 위해 null_resource 리소스를 사용할 수 있다.

```
resource "aws_instance" "foo" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t3.micro"

    private_ip = "10.0.0.12"
    subnet_id = aws_subnet.tf_test_subnet.id
}

resource "aws_eip" "bar" {
    instance = aws_instance.foo.id
    associate_with_private_ip = "10.0.0.12"
    depends_on = [aws_internet_gateway.gw]
}

resource "null_resource" "foo" {
    provisioner "remote-exec" {
        connection {
            host = aws_eip.bar.public_ip
        }
        inline = [
            "echo ${aws_eip.bar.public_ip}"
        ]
    }
}
```

- null_resource는 정의된 속성이 `id`가 전부이므로, 선언된 내부의 구성이 변경되더라도 새로운 Plan 과정에서 실행 계획에 포함되지 못한다.
- 따라서 사용자가 null_resource에 정의된 내용을 강제로 다시 실행하기 위한 인수로 trigger가 제공됨
- `trigger`는 임의의 string 형태의 map 데이터를 정의하는데, 정의된 값이 변경되면 null_resource 내부에 정의된 행위를 다시 실행

```
resource "null_resource" "foo" {
    triggers = {
        ec2_id = aws_instance.bar.id # instance의 id가 변경되는 경우 재실행
    }
#   ... 생략
}

resource "null_resource" "barz" {
    triggers = {
      ec2_id = time() # terraform 실행 계획을 생성할 때 마다 재실행
    }
#   ... 생략
}
```

#### 3.13.2 terraform_data

> 테라폼 1.4 버전부터 도입된 리소스로, null_resource 리소스를 대체하는 리소스

- 이 리소스 또한 자체적으로 아무것도 수행하지 않지만 null_resource는 별도의 `프로바이더` 구성이 필요하다는 점과 비교하여 추가 프로바이더 없이 테라폼 자체에 포함된 기본 수명주기 관리자가 제공된다는 것이 장점

##### 시나리오

- 기존 null_resource 와 동일하며 강제 재실행을 위한 triggers_replace와 상태 저장을 위한 input 인수와 input에 저장된 값을 출력하는 output 속성이 제공됨
- trigers_replace에 정의되는 값이 기존 map형태에서 tuple 형태로 변경됨

```
resource "terraform_data" "foo" {
    triggers_replace = [
        aws_instance.bar.id,
        aws_instance.barz.id
    ]

    input = "world"
}
output "terraform_data_output" {
    value = terraform_data.foo.output # 출력 결과는 "world"
}
```

### 3.14 moved 블록

> `terraform` `State`에 기록되는 리소스 주소의 이름이 변경되면 기존 리소스는 삭제되고 새로운 리소스가 생성됨을 앞서 설명에서 확인함.

##### 테라폼 리소스 선언하다 보면 이름을 변경해야 하는 상황 발생

- **리소스 이름을 변경**
- **`count`로 처리하던 반복문을 for_each로 변경**
- **리소스가 모듈로 이동하여 참조되는 주소가 변경**

> `moved` 단어가 의미하는 것처럼 테라폼 State에서 옮겨진 대상의 이전 주소와 새 주소를 알리는 역할을 수행함.

- `moved` 블록 이전에는 `State`를 직접 편집하는 terraform state mv 명령어 사용
- `moved` 블록은 `State`에 접근 권한이 없는 사용자라도 변경되는 주소를 리소스 영향 없이 반영할 수 있다.

```
resource "local_file" "a" {
    content = "foo!"
    filename = "${path.module}/foo.bar"

}

output "file_content" {
    value = local_file.a.content
}
```

local_file `a` -> `b` 이름 변경

```
resource "local_file" "b" {
    content = "foo!"
    filename = "${path.module}/foo.bar"

}

output "file_content" {
    value = local_file.b.content
}

terraform plan
Plan: 1 to add, 0 to change, 1 to destroy.
```

> local_file.a의 `프로비저닝` 결과를 유지한 채 이름을 변경하기 위해 moved 블록을 사용

```
resource "local_file" "b" {
    content = "foo!"
    filename = "${path.module}/foo.bar"

}
moved {
    from = local_file.a
    to = local_file.b
}

output "file_content" {
    value = local_file.b.content
}
terraform plan

Terraform will perform the following actions:

  # local_file.a has moved to local_file.b
    resource "local_file" "b" {
        id                   = "4bf3e335199107182c6f7638efaad377acc7f452"
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```

실행 계획상 제거되거나 새로 생성되는 리소스는 없고, 출력 결과에 local_file.a 주소가 local_file.b 주소로 변경되었음을 알 수 있다.

### 3.15 CLI를 위한 시스템 변수

> 테라폼 환경 변수를 통해 실행 방식과 출력 내용에 대한 옵션을 조절할 수 있다.
> 시스템 환경 변수를 설정하면, 영구적으로 로컬 환경에 적용되는 옵션이나 별도 서버 환경에서 실행하기 위한 옵션을 부여할 수 있다.

- Mac/Linux/Unix : export <환경 변수 이름>=<값>
- Windows : set <환경 변수 이름>=<값>
- Windows PowerShell : $Env:<환경 변수 이름>='<값>'

#### 3.15.1 TF_LOG

> 테라폼의 `stderr` 로그에 대한 레벨을 정의

- trace, debug, info, warn, error, off
- 환경 변수가 없는 경우 off와 동일

**로그 관련 환경 변수 설명**

    - TF_LOG : 로깅 레벨 지정 또는 해제
    - TF_LOG_PATH : 로그 파일 경로 지정
    - TF_LOG_CORE : TF_LOG와 별도로 테라폼 자체 코어에 대한 로깅 레벨 지정 또는 해제
    - TF_LOG_PROVIDER : TF_LOG와 별도로 테라폼에서 사용하는 프로바이더에 대한 로깅 레벨 지정 또는 해제

```
➜  3.13 git:(main) ✗ TF_LOG=info terraform plan
2025-12-10T23:18:58.625+0900 [INFO]  Terraform version: 1.14.0
2025-12-10T23:18:58.625+0900 [INFO]  Go runtime version: go1.25.4
2025-12-10T23:18:58.625+0900 [INFO]  CLI args: []string{"terraform", "plan"}
2025-12-10T23:18:58.626+0900 [INFO]  CLI command args: []string{"plan"}
2025-12-10T23:18:58.947+0900 [INFO]  backend/local: starting Plan operation
2025-12-10T23:18:58.949+0900 [INFO]  provider: configuring client automatic mTLS
2025-12-10T23:18:58.963+0900 [INFO]  provider.terraform-provider-local_v2.6.1_x5: configuring server automatic mTLS: timestamp="2025-12-10T23:18:58.963+0900"
2025-12-10T23:18:58.972+0900 [INFO]  provider: plugin process exited: plugin=.terraform/providers/registry.terraform.io/hashicorp/local/2.6.1/darwin_arm64/ter
```

#### 3.15.2 TF_INPUT

> 값을 `false` or `0`으로 설정하면 테라폼 실행 시 인수에 `-input=false` 또는 `-input=0` 와 동일한 효과

```
  3.13 git:(main) ✗ TF_INPUT=0 terraform plan
╷
│ Error: No value for required variable
│
│   on main.tf line 93:
│   93: variable "my_var" {}
│
│ The root module input variable "my_var" is not set, and has no default value. Use a -var or -var-file command line argument to provide a value for this
│ variable.
```

#### 3.15.3 TF_VAR_name

> TF_VAR\_<변수이름> 을 사용하면 입력 시 또는 default 로 선언된 변수 값을 대체한다.

**입력 방식은 3.6절에서 확인함**

#### 3.15.4 TF_CLI_ARGS / TF_CLI_ARGS_subcommand

> 테라폼 실행 시 추가할 인수를 정의한다.

- `TF_CLI_ARGS="-input=false" terraform apply -auto-approve` = `terraform apply -input=false -auto-approve`

```
➜  3.13 git:(main) ✗ export TF_CLI_ARGS_apply="-input=false"
➜  3.13 git:(main) ✗ terraform apply -auto-approve
╷
│ Error: No value for required variable
│
│   on main.tf line 93:
│   93: variable "my_var" {}
│
│ The root module input variable "my_var" is not set, and has no default value. Use a -var or -var-file command line argument to provide a value for this
│ variable.
➜  3.13 git:(main) ✗ terraform plan
var.my_var
  Enter a value:
```

> `export TF_CLI_ARGS_apply="-input-false"` 를 환경 변수로 사전에 차단해놔 `terraform apply` 실행 시 `-input=false` 인수를 추가하지 않아도
> 동일하게 동작한다.

#### 3.15.5 TF_DATA_DIR

> `State` 저장 백엔드 설정과 가은 작업 디렉토리별 데이터를 보관하는 위치를 지정한다. 이 데이터는 `.terraform` 디렉토리 위치에 기록되지만
> TF_DATA_DIR에 경로가 정의되면 기본 경로를 대체하여 사용한다.

- 일관된 테라폼 사용을 위해서 해당 변수는 실행 시마다 일관되게 적용될 수 있도록 설정하는 것이 중요하다.
- 설정 값이 이전 실행 시에만 적용되는 경우 init 명령으로 수행된 모듈, 아티팩트 등의 파일을 찾지 못한다.
- 이미 `terraform init`이 수행된 상태에서 TF_DATA_DIR로 경로를 재지정하고 실행하는 경우 플러그인 설치가 필요하다는 메시지 출력을 확인할 수 있다.

```
➜  3.13 git:(main) ✗ TF_DATA_DIR=./.terraform_tmp terraform plan
╷
│ Error: Required plugins are not installed
│
│ The installed provider plugins are not consistent with the packages selected in the dependency lock file:
│   - registry.terraform.io/hashicorp/local: there is no package for registry.terraform.io/hashicorp/local 2.6.1 cached in .terraform_tmp/providers
│
│ Terraform uses external plugins to integrate with a variety of different infrastructure services. To download the plugins required for this configuration,
│ run:
│   terraform init
╵
```

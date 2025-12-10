# 테라폼 명령어 설명

### 3.1.2 terraform init

> terraform [global options] init [options]

- 구성 파일이 있는 작업 directory를 초기화하는데 사용됨
- 이 작업을 실행하는 directory를 루트 모듈이라 부름
- 자동화 구성을 위한 파이프라인 설계 시 테라폼을 실행하는 시점에 필수적으로 요청되는 명령어임

```
terraform init
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.6.1...
- Installed hashicorp/local v2.6.1 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- 작업 당시의 버전 정보를 기입하고, .terraform.lock.hcl 파일이 있으면 해당 파일에 명시된 버전으로 init을 수행한다.
- 작업자가 의도적으로 버전을 변경하거나 코드에 명시한 다른 버전으로 변경하려면 terraform init -upgrade를 수행해야 함

---

### 3.1.3. validate

> terrafrom [global options] validate [options]

- 커맨드 단어 의미대로 directory에 있는 테라폼 구성 파일의 유효성을 확인
- 대상이 되는 인프라와 서비스의 상태를 확인하기 위한 원격 작업 및 API 작업은 발생하지 않음
- 코드적인 유효성만 검토
- 테라폼 plan 동작과 달리 작성된 구성의 문법, 종속성, 속성 이름이나 연결된 값의 정확성 확인을 수행한다.

```
terraform validate
╷
│ Error: Missing required argument
│
│   on main.tf line 1, in resource "local_file" "abc":
│    1: resource "local_file" "abc" {
│
│ The argument "filename" is required, but no definition was found.
```

```
terraform validate
Success! The configuration is valid.
```

#### 3.1.3.1 -no-color

- 대부분의 명령어와 함께 사용가능
- 로컬이 아닌 외부 실행 환경 (jenkins, HCP Terraform, Terraform Enterprise, Githun Action 등)을 사용하는 경우 <-[0m<-[1m 와 같은 색상 표기 문자가 표기될 수 있다.
- 색상 표기 문자 없이 출력한다.

```
terraform validate -no-color

Error: Missing required argument

  on main.tf line 1, in resource "local_file" "abc":
   1: resource "local_file" "abc" {

The argument "filename" is required, but no definition was found.
```

#### 3.1.3.2 -json

- 실행 결과를 json 형식으로 출력 가능
- 프로비저닝 파이프라인을 설계하는 경우 결과에 대한 쿼리가 필요할 수 있다.
- json 형태의 출력 데이터를 이용하면 프로비저닝 과정의 조건 및 데이터로 사용 가능하다.

```
terraform validate -json
{
  "format_version": "1.0",
  "valid": false,
  "error_count": 1,
  "warning_count": 0,
  "diagnostics": [
    {
      "severity": "error",
      "summary": "Missing required argument",
      "detail": "The argument \"filename\" is required, but no definition was found.",
      "range": {
        "filename": "main.tf",
        "start": {
          "line": 1,
          "column": 29,
          "byte": 28
        },
        "end": {
          "line": 1,
          "column": 30,
          "byte": 29
        }
      },
      "snippet": {
        "context": "resource \"local_file\" \"abc\"",
        "code": "resource \"local_file\" \"abc\" {",
        "start_line": 1,
        "highlight_start_offset": 28,
        "highlight_end_offset": 29,
        "values": []
      }
    }
  ]
}
```

### 3.1.4 -plan & -apply

> terraform [global options] plan [options]
> terraform [global options] apply [options] [PLAN]

#### 3.1.4.1 -plan

- 변경 사항을 실제로 적용하지는 않으므로, 적용 전에 예상한 구성이 맞는지 검토 하는 데 주로 이용
- 테라폼 실행 이전의 상태와 비교해 현재 상태가 최신화되었는지 확인
- 적용하고자 하는 구성을 현재 상태와 비교하고 변경점을 확인
- 구성이 적용되는 경우 대상이 테라폼 구성에 어떻게 반영되는지 확인한다.

#### 3.1.4.2 -apply

- plan에서 작성된 적용 내용을 토대로 작업을 실행함
- terraform plan 명령으로 생성되는 실행 계획이 필요, 만약 없다면 새 실행 계획을 자동으로 생성하고 해당 계획을 승인할 것인지 묻는 메시지가 표시

```
➜  03.start git:(main) ✗ terraform plan
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.abc will be created
  + resource "local_file" "abc" {
      + content              = "abc!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = ....
  }
Plan: 1 to add, 0 to change, 0 to destroy.
```

> 심볼이 가진 의미를 설명해줌

- 현재는 기존에 생성된 리소스가 없으므로, 앞선 구성 파일 내용을 바탕으로 새로 생성해야 하기에 + 기호만 나타남.
- 그 아래에는 테라폼 구성 내용을 바탕으로 어떤 리소스가 생성되는지 상세 내역을 보여줌
- 실행 계획 -> local_file 리소스를 정의할 때 필수 요소인 content와 filename만 선언 했지만, 리소스에 정의 가능한 다른 옵션의 내용과 기본값이 자동으로 입력되어 적용되는것을 알 수 있음.
  > Plan: 1 to add, 0 to change, 0 to destroy.
  > -> 결과는 이 구성을 적용할 경우 하나의 리소스가 추가되고, 변경되거나 삭제되는 것은 없다고 알려주는 뜻

```
➜  03.start git:(main) ✗ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.abc will be created
  + resource "local_file" "abc" {
      + content              = "abc!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./abc.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

### 3.1.4.3 -detailed-exitcode

- 실행 계획 생성 명령과 함께 사용하지 좋은 추가 옵션
- 옵션이 없던 때와 결과는 같지만 exitcode가 환경 변수로 구성

### 3.1.4.4 plan -out=tfplan

```
Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
```

> -out=<filename> 형식으로 파일 이름이 정해져 terraform plan으로 생성되는 실행 계획이 파일로 생성

- 바이너리 형태 -> 안에 내용 확인 불가
- tfplan이라는 이름은 정해진 것이 아님 -> 다른 이름 자유자재로 사용가능
- 다른 파일과 혼동할 수 있는 별도의 확장자는 붙이지 않는것이 좋음

### 3.1.4.5 terraform apply <파일이름(filename)>

```
➜  03.start git:(main) ✗ terraform apply tfplan
local_file.abc: Creating...
local_file.abc: Creation complete after 0s [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

- 앞에 terraform apply는 plan에서의 동일한 동작을 먼저 실행 -> 해당 실행 계뢱을 적용할 것인지 묻는 과정
- terraform apply <파일이름> -> 즉시 적용

```
➜  03.start git:(main) ✗ terraform apply
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

> 프로비저닝이 완료된 이후 terraform apply 실행 시 작성되는 실행 계획이 없음

- 테라폼은 선언적 구성 관리를 제공하는 언어로 멱등성을 갖고, 이후에 추가로 설명될 상태를 관리하기 때문에 동일한 구성에 대해서는 다시 실행하거나 변경하는 작업을 수행하지 않음.
- 변경 없는 구성에서는 plan단게에서 변경 사항이 없기 때문에 출력되는 메시지 내용 (No changes. Your infrastructure matches the configuration.) 처럼 프로비정닝 동작이 발생 X

```
resource "local_file" "abc" {
  content = "abc!"
  filename = "${path.module}/abc.txt"
}

resource "local_file" "def" {
  content = "def!"
  filename = "${path.module}/def.txt"
}

➜  03.start git:(main) ✗ terraform apply
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]
... 생략 ...
Terraform will perform the following actions:

  # local_file.def will be created
  + resource "local_file" "def" {
      + content              = "def!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./def.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.def: Creating...
local_file.def: Creation complete after 0s [id=15f946cb27f0730866cefea4f0923248d9366cb0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

```
➜  03.start git:(main) ✗ terraform apply tfplan
╷
│ Error: Saved plan is stale
│
│ The given plan file can no longer be applied because the state was changed by another operation after the plan was created.
╵
```

```
resource "local_file" "abc" {
  content = "abc!"
  filename = "${path.module}/abc.txt"
}

# resource "local_file" "def" {
#   content = "def!"
#   filename = "${path.module}/def.txt"
# }

```

> terraform apply -> yes

- def.txt 파일이 삭제됨

일반적으로 로컬에서는 사용자 혼자 테스트하고 실행할 때 terraform plan은 코드 작성 중 검증의 용도로 주로 활용
terraform apply 명령으로만 리소스를 생성하는 경우가 주로 이룬다.
하지만 인프라에 대한 외부 실행 환경 구성 시 앞서 확인한 **terraform validate** & **terraform plan**을 먼저 실행해 변경 사항 적용 전에 검증하고
승인하는 단계를 추가할 수 있으므로 두 동작을 분리해 사용해야함.

### 3.1.4.6 -replace

> 프로비저닝이 완료된 이후 terraform plan과 terraform apply 실행 시 코드 변경이 없다면 실행 계획에 프로비저닝할 대상이 없지만, 사용자가 필요에 의해 특정 리소스를 다시 생성해야하는 경우 -replace 옵션으로 대상 리소스 주소를 지정하면 대상을 삭제 후 생성하는 실행계획 발생

```
➜  03.start git:(main) ✗ terraform apply -replace=local_file.abc
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.abc will be replaced, as requested
-/+ resource "local_file" "abc" {
...
  # (4 unchanged attributes hidden)
}
Plan: 1 to add, 0 to change, 1 to destroy.
```

- terraform plan & terraform apply 모두 적용 가능하고, 여러 번 적용 가능한 옵션이다.
- 이전에는 **terraform taint <리소스 주소>** 명령으로 재생성 대상을 지정하는 방식을 우선 적용하는 방식이었으나 **사용되지 않을 명령어**로 구분

### 3.1.5 destroy

> terraform [global options] destroy [options]

- 테라폼 구성에서 관리하는 모든 개체를 제거하는 명령어
  제거 명령 방법

1. 리소스 일부만 제거하기 위해서는 테라폼 선언적 특성에 따라 삭제하려고 하는 코드를 제거하고, terraform apply를 실행하는 방안
2. 모든 개체를 제거하는 게 목적 -> terraform destroy 수행 === terraform apply -destroy
   **따라서 destroy도 앞서 plan & apply의 관계 처럼 실행 계획이 필요**

- terraform destroy를 위한 실행 계획 생성은 terraform plan -destroy와 같다.
- terraform plan으로 실행 계획을 미리 바이너리 형태의 파일로 작성하고 terraform apply를 실행했던 것처럼 단게를 나누어 실행하는 것도 가능

```
➜  03.start git:(main) ✗ terraform destroy
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # local_file.abc will be destroyed
  - resource "local_file" "abc" {
      - content              = "abc!" -> null
      - content_base64sha256 = "U+Dv8yBGJvPiVspjZXLXzN+OtaGQyd76P6VnvGOGa3Y=" -> null
      - content_base64sha512 = "J873Ugx5HyDEnYsjdX8iMBjn4I3gft82udsl3lNeWEoqwmNE3mvUZNNz4QRqQ3iaT5SW1y9p3e1Xn2txEBapKg==" -> null
      - content_md5          = "4edb03f55c86d5e0a76f5627fa506bbf" -> null
      ...
  }
Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: no

Destroy cancelled.
```

- terraform apply와 같이 삭제 여부를 묻는다.
- yes가 아닌 다른 답을 했을 때는 terraform plan -destroy와 같다.

> 앞서 실행계획을 파일로 미리 생성하고 적용하는 과정을 살펴보았다.
> **terraform plan -destroy -out=tfplan** 처럼 실행 계획을 만들고 terraform apply로 해당 계획 실행 가능
> -> 이또한 실행을 위한 파이프라인 구성 시 활용할 수 있는 방안

#### 3.1.5.1 -auth-approve

- 자동 승인 기능을 부여하는 옵션

> **terraform apply & terraform destroy** 작업은 사전 실행 계획이 없으면 실행 계획을 작성하고 사용자에게 승인을 요청

```
➜  03.start git:(main) ✗ terraform destroy
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:
...생략...
Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

이와 같이 승인을 요청함

```
➜  03.start git:(main) ✗ terraform destroy -auto-approve
local_file.abc: Refreshing state... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:
...생략...
Plan: 0 to add, 0 to change, 1 to destroy.
local_file.abc: Destroying... [id=5678fb68a642f3c6c8004c1bdc21e7142087287b]
local_file.abc: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

> 승인 요청없이 자동으로 승인처리 한다.
> **terraform apply -auto-approve도 마찬가지로 된다.**

### 3.1.6 fmt

> terraform fmt [options] [DIR]

- format의 줄임 표기인 fmt 명령어는 테라폼 구성 파일을 표준 형식과 표준 스타일로 적용하는데 사용됨
- 구성 파일에 작성된 테라폼 코드의 가독성을 높이는 작업에 사용됨
- ex. code 협업 과정에서 각 작업자별로 코드 작성에 쓰인 정렬, 빈칸, 내려쓰기 등의 규칭이 다른 경우에 유용

**최종적으로 코드를 공유하는 시스템에 업로드하기 전에 이 커맨드를 수행하면 코드 자체의 변경이 아닌 스타일의 차이로 생긴 코드 중복처리가 가능해 업데이트를 촤소화가능**

```
➜  03.start git:(main) ✗ terraform fmt
main.tf
```

- 적용된 대상 파일이 목록에 표시
- 파일을 열면 코드 내의 띄어쓰기, 인수와 드로 인수값을 손쉽게 정렬한 결과를 확인할 수 있다.

```
적용 전
resource "local_file" "abc" {
content  = "abc!"
filename = "${path.module}/abc.txt"
}
```

```
적용 후
resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}
```

- 함께 많이 사용하는 보조 옵션으로는 "재귀적"이라는 의미인 -recursive 옵션이 있음 이것은 하위 디렉토리의 테라폼 구성 파일을 모두 포함해 적용한다.

> 살펴본 커맨드 외에 테라폼 코드 작성 시 기능 및 문법을 간단히 확인할 수 있는 console, 상태 관리를 위한 state, 작업 공간 관리를 위한 workspace, 테라폼 코드로 생성되지 않은 리소스를 관리하기 위해 상태를 가져오는 import, HCP Terraform 또는 Terraform Enteprise의 인증 정보를 관리하는 login, logout 등의 커맨드가 존재. 각 커맨드는 이후 과정에서 추가로 설명

---

### 3.2 HCL

> HCL은 하시코프사에서 IaC와 구성 정보를 명시하기 위해 개발된 오픈소스 도구.

- Infrastructure as Code는 수동 프로세스가 아닌 코드를 통해 인프라를 관리하고 프로비저닝 하는 것을 말함.
- 테라폼은 이전의 프로비저닝 방식을 개선하고 코드적인 동작 메커니즘과 IaC의 핵심인 코드를 잘 만들고 관리할 수 있는 도구를 제공
- 테라폼에선 HCL이 코드의 영역을 담당
- 이 코드는 곧 인프라 -> 선언적 특성을 갖게 되고 튜링 완전한 언어적 특성을 갖는다.
- 쉽게 버저닝해 히스토리를 관리하고 함께 작업할 수 있는 기반을 제공.

### 3.2.1 HCL을 사용하는 이유

- 다수의 프로비저닝 대상 인프라와 서비스는 JSON과 YAML 방식의 기계 친화적인 언어로 소통함.
  > 왜 JSON or YAML 같은 방식이 아닌가?
- 하시코프에서는 HCL 이전에 Ruby 같은 여타 프로그래밍 언어를 사용해 JSON 같은 구조를 만들어 내기 위해 노력함.
- 사람에게 친화적인 언어를 원하고, 어떤 사용자는 기계 친화적인 언어를 원함.
- JSON은 이러한 두 개 요구에 다 잘 맞지만, 구문이 길어지고 주석지원 x(weakness)
- YAML은 처음 접하는 사용자가 실제 구조를 만들어내고 익숙해지는 데 어렵고, 관리 대상이 많아지고, 구성이 복잡해질 경우 리소스 구성을 파악하기 어려움.
- 더불어 일반적인 언어 사용시 프로비저닝 목적 이상의 많은 기능을 내장하고 있는 데서 문제가 생김
- 작업자들이 모두 선호하는 언어를 골라 정하기도 어려움

```
HCL을 이용한 테라폼 구성
resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}

JSON으로 표현된 테라폼 구성
{
  "resource" : {
    "local_file" : {
      "abc": {
        "content": "abc!",
        "filename": "${path.module}/abc.txt"
      }
    }
  }
}
```

> HCL에서 변수와 문자열 값을 함께 사용하는 인터폴레이션 표현 방식을 JSON을 사용하는 다른 IaC 도구와 비교하면 아래와 같음

```
HCL을 이용한 테라폼 구성
name = "${var.PilotServeNane}-vm"

JSON을 이용한 CloudFormation 구성
"name": "{"Fn::Josin":["-",[PilotServeName,vm]]}"
```

### 3.2.2 HCL 표현식

- HCL 표현식 예시

```
// 한줄 수석 방법1
# 한줄 수석 방법2

/*
라인 주석
*/

locals {
    key1 = "value1" # = 를 기준으로 키와 값이 구분
    myStr = "TF UTF-8" # UTF-8 문자를 지원
    multiStr = <<EOF
Multi
Line
String
with anytext
EOF
    # Linux/macOS 에서는 EOF 같은 여러줄의 문자열을 지원

boolean1 = true # boolean true
boolean2 = false # boolean false를 지원

decimal = 123 # 기본적으로 숫자는 10진수
octal = 0123 # 0으로 시작하는 숫자는 8진수
hexadecimal = "0xD5" # 0x 값을 포함하는 스트링은 16진수
scientific = 1e10 # 과학 표기법도 지원

#function의 호출 예
myprojectname = format("%s is myproject name", var.project)

# 3항 연산자 조건문을 지원
credentials = var.credentials == "" ? file(var.credentials_file): var.credentials

}
```

HCL 표현식에서는 일반적으로 코드에서 사용되는 주석 표기부터 변수 정의 등을 포함하고 프로그래밍적인 연산과 구성 편의성을 높이기 위한 function도 제공

> 테라폼으로 인프라를 구성하기 위한 선언 블록도 다음과 같이 다수 존재

- terraform 블록
- resource 블록
- data 블록
- variable 블록
- local 블록
- output 블록

### 3.3 테라폼 블록

> 테라폼의 구성을 명시하는데 사용 -> 테라폼 버전과 같은 값들은 자동으로 설정 -> 다른 사람과 작업할 때는 버전을 명시적으로 선언하고 필요한 조건을 입력하여 실행 오류를 최소화해야함

```

terraform {
    required_version = "~> 1.8.0" # 테라폼 버전

    required_providers { # 프로바이더 버전을 나열
        random = {
            version = ">=3.0.0, < 3.6.0"
        }
        aws = {
            version = "~> 5.0"
        }
    }

    cloud { # HCP/Enterprise 같은 원격 실행을 위한 정보
        organization = "<MY_ORG_NAME>"

        workspaces {
          name = "my-first-workspace"
        }

    }
    backend "local" { # state를 보관하는 위치를 저장
        path = "relative/path/to/terraform.tfstate"
    }
}
```

> 버전 표기에 대해 알아보기

- 테라폼 내에서 버전이 명시되는 terraform, module에서 사용 가능하며 버전에 대한 제약을 둠으로써 테라폼, 프로바이더, 모듈이 항상 의도한 정의대로 실행되는 것을 목적으로 함.
- 버전 체께는 시맨틱 버전 관리 방식을 따름

```
# version = Major.Minor.Patch
version = 1.8.5
```

- 시맨틱 버전 관리 방식을 이해하면 테라폼과 프로바이더의 버전 업그레이드 시 영향도를 추측가능, 모듈화의 결과물을 공유하는 방식에도 적용가능
  - Major Version : 내부 동작의 API가 변경 또는 삭제되거나 하위 호완이 되지 않는 버전
  - Minor Version : 신규 기능이 추가되거나 개선되고 하위 호환이 가능한 버전
  - Patch Version : 버그 및 일부 기능이 개선된 하위 호환이 가능한 버전

> 버전 제약 구문 연산자

- = 또는 연산자 없음 : 지정된 버전만을 허용하고 다른 조관과 병기할 수 없음
- != : 지정된 버전을 제외
- ">, >=, <, <=" : 지정한 버전과 비교해 조건에 맞는 경우 허용
- ~> : 지정한 버전에서 가장 자릿수가 낮은 구성 요소만 증가하는 것을 허용 ~> x.y인 경우 y 버전에 대해서만, ~> x.y.z인 경우 z 버전에 대해서만 보다 큰 버전을 허용

> 테라폼 버전 관리로 비유된 선언 방식의 의미
> 선언된 버전 -> 의미 -> 고려사항
> -> 1.0.0 -> terraform v1.0.0만을 허용 -> terraform을 업그레이드 하기 위해서는 선언된 버전을 변경해야만 함
> -> >= 1.0.0 -> terraform v1.0.0 이상의 모든 버전을 허용 -> v1.0.0 버전을 포함해 그 이상의 모든 버전을 허용해 실행된다.
> -> ~> 1.0.0 -> terraform v1.0.0을 포함한 v1.0.x 버전을 허용하고 v1.x.y x는 허용하지 않음 -> 부버전에 대한 업데이트는 무중단으로 이루어짐
> -> >= 1.0, < 2.0.0 -> terraform v1.0.0 이상 v2.0.0 미만인 버전을 허용 -> 주버전에 대한 업데이트를 방지

### 3.3.1 테라폼 버전

> required_version으로 정의되는 테라폼 버전은 지정된 조건과 일치하지 않는 경우 오류를 출력하고 이후 동작을 수행하지 않는다.

- 협업 환경에서 테라폼의 버전 관련 조건을 사용해 모든 구성원이 특정 테라폼 버전을 사용하고, 최소 요구 버전에 대해 명시할 수 있음.

**required_version**으로 제어되는 버전 제한을 확인해보기 위해 기존 main.tf에 terraform 블록과 관련 값을 추가.

- 의도적으로 버전을 제한하는 테스트 -> 현재 실행되는 테라폼 버전보다 낮게 설정

```
terraform {
  required_version = "< 1.0.0"
}

resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}
➜  03.start git:(main) ✗ terraform init
Initializing HCP Terraform...
╵
╷
│ Error: Unsupported Terraform Core version
│
│   on main.tf line 2, in terraform:
│    2:   required_version = "< 1.0.0"
│
│ This configuration does not support Terraform version 1.14.0. To proceed, either choose another supported Terraform version or update this version
│ constraint. Version constraints are normally set for good reason, so updating the constraint may lead to other errors or unexpected behavior.

```

> 작성된 코드에서는 지원되지 않는 테라폼 버전이라는 메시지 출력

```
terraform {
  required_version = "> 1.0.0"
}

resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}
➜  03.start git:(main) ✗ terraform init
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/local from the dependency lock file
- Using previously-installed hashicorp/local v2.6.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### 3.3.2 프로바이더 버전

> 테라폼 0.13 버전 이전에는 provider 블록에 함께 버전을 명시했지만 해당 버전 이후 프로바이더 버전은 terraform 블록에서 required_providers에 정의

_테라폼 레지스트리 - https://registry.terraform.io/browse/providers_

- 각 프로바이더의 이름에 소스 경로와 버전을 명시하며, 테라폼 레지스토리 공식 페이지에서 원하는 프로바이더를 선택한 다음 화면에서 우측 상단의 [USE PROVIDER]를 클릭하면 테라폼 코드에 해당 버전을 사용하는 샘플 코드가 표기

```
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 10000.0.0"
    }
  }

}

resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}

➜  03.start git:(main) ✗ terraform init -upgrade
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching ">= 10000.0.0"...
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/local: no available releases match the given constraints >= 10000.0.0
│
│ To see which modules are currently depending on hashicorp/local and what versions are specified, run the following command:
│     terraform providers
╵
```

- 실제 가용한 버전의 프로바이더가 없음 -> init 실패
- 올바른 버전 제한을 선언하기 위해 local 프로바이더 버전을 >= 2.0.0으로 수정 -> terraform init -upgrade

```
➜  03.start git:(main) ✗ terraform init -upgrade
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching ">= 2.0.0"...
- Using previously-installed hashicorp/local v2.6.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### 3.3.3 cloud 블록

> HCP Terraform, Terraform Enterprise는 CLI, VSC, API 기반의 실행 방식을 지원하고 cloud 블록으로 선언
> **cloud 블록은 1.1버전에 추가된 선언으로 기존에는 State 저장소를 의미하는 backend의 remote 항목으로 설정했다. hostname은 기본값 app.terraform.io를 가르키며, 해당 주소는 HCP Terraform의 URL이다.**

> 테라폼 버전에 따른 HCP Terraform, Terraform Enterprise 연동 정의 차이

```
v1.1 이전
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "my-org"
    workspaces {
      name = "my-app-prod"
    }
  }
}

v1.1 이후
terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "my-org"
    workspaces {
      name = "my-app-prod"
    }
  }
}
```

### 3.3.4 백엔드 블록

> 백엔드 블록의 구성은 테라폼 실행 시 저장되는 State(상태 파일)의 저장 위치를 선언한다.

- **주의할 점** -> **하나의 백엔드만 허용** 한다는 점
- 테라폼은 State의 데이터를 사용해 코드로 관리된 리소스를 탐색하고 추적
- 작업자 간의 협업을 고려한다면 테라폼으로 생성한 리소스의 상태 저장 파일을 공유할 수 있는 외부 백엔드 저장소가 필요
- State에는 외부로 노출되면 안되는 패스워드 또는 인증서 정보 같은 민감한 데이터들이 포함될 수 있으므로 State의 접근 제어 필수

#### 3.3.4.1 State 잠금 동작

> 기본적으로 활성화하는 백엔드는 local -> 상태를 작업자의 로컬 환경에 저장하고 관리하는 방식

- 이 밖의 다른 백엔드 수엉은 동시에 여러 작업자가 접근해 사용할 수 있도록 공유 스토리지 같은 개념을 갖는다.
- 공유되는 백엔드에 State가 관리되면 테라폼이 실행되는 동안 **.terraform.tfstate.lock.info** 파일이 생성되면서 해당 State를 동시에 사용하지 못하도록 잠금 처리를 함.
- 파일 생성을 확인하고 싶으면 terraform apply 실행하고 생성되는 잠금 파일 확인

```
.terraform.tfstate.lock.info

{"ID":"6fe7cbf7-c067-2197-2572-5e0a8fde35bb","Operation":"OperationTypeApply","Info":"","Who":"hwangbongsu@hwangbongsuui-MacBookPro.local","Version":"1.14.0","Created":"2025-12-02T14:39:23.535441Z","Path":"terraform.tfstate"}
```

> 터미널 두개 띄우고 둘다 terraform apply 처음 실행은 yes or no 아무것도 입력 x

```
새로운 터미널에서의 terraform apply

➜  terraform git:(main) ✗ terraform apply
╷
│ Error: No configuration files
│
│ Apply requires configuration to be present. Applying without a configuration would mark everything for destruction, which is
│ normally not what is desired. If you would like to destroy everything, run 'terraform destroy' instead.
```

> 동시에 동일한 State에 접근이 발생했으므로 잠금 파일의 내용이 표기되면서 에러가 발생

#### 3.3.4.2 백엔드 설정 변경

- 백엔드가 설정되면 다시 init 명령을 수행해 State의 위치를 재설정해야함.
- 백엔드 블록에 local을 정의해 terraform init을 수행해본다.

> 기존에 이미 한번이라도 State가 생성된 terraform 코드인 경우 terraform init을 수행할 때 백엔드 설정이 변경됨에 따라 다음과 같은 메시지를 확인할 수 있음

```
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ... 생략
  }

}

terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

resource "local_file" "abc" {
  ... 생략
}

➜  03.start git:(main) ✗ terraform init
Initializing the backend...
Do you want to copy existing state to the new backend?

  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "local" backend. No existing state was found in the newly
  configured "local" backend. Do you want to copy this state to the new "local"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value:
```

- 백엔드 정보를 테라폼이 내부 메타데이터에 기록한다는 것을 의미.
  > 새로운 백엔드로의 전환을 위해 **두 가지 조건**이 제공됨
- 이전 구성 유지 : -migrate-state는 terraform.ftstate의 이전 구성에서 최신의 state 스냅샷을 읽고 기록된 정보를 새 구성으로 전환
- 새로 초기화 -reconfigure는 init을 실행하기 전에 terraform.ftstate 파일을 삭제해 테라폼을 처음 사용할 때처럼 이 작업 공간(directory)을 초기화하는 동작

> -migrate-state 옵션을 적용한 State 재선언

- 백엔드 구성에서 path에 새로운 경로가 추가되었으므로 새로운 디렉토리가 생성되는 것을 확인할 수 있음
- 기존 State가 있고 새로 지정한 백엔드에선 State를 발견할 수 없으므로 새로운 백엔드로의 복사 여부를 물어봄. 'yes'를 입력하고 진행하면 기존 State파일을 새로운 경로의 파일로 복제함 ('no'를 입력했다면 State는 복사되지 않고, 사용자가 추후 새로 지정한 백엔드이 현재의 State를 복사하지 않는다면 테라폼은 현재 상태와 무관하게 다시 동작을 수행)

- -reconfigure로 실행하는 경우 -> terraform.tfstate를 재구성하므로 -migrate-state 옵션과는 달리 백엔드 구성이 변경되었다는 로그를 발견할 수가 없음

> 백엔드를 전환하는 것은 State관리가 되는 저장소를 선택하는 것과 같다. 백엔드를 다중으로 선택할 수 없기 때문에 만약 State의 안전한 보관을 고려한다면 대상 백엔드 저장소가 고가용성과 백업이 지원되는 대상을 고려할 수가 있다.

### 3.4 리소스

> 리소스는 테라폼이 프로비저닝 도구라는 측면에서 가장 중요한 요소

- 리소스 블록은 선언된 항목을 생성하는 동작을 수행.
- 앞서 선언한 local_file을 통해 새로운 파일이 생성되는 것을 확인함.

#### 3.4.1 리소스 구성

> 리소스 블록은 resource로 시작

- 리소스 이름은 첫 번째 언더스코어인 \_를 기준으로 앞은 프로바이더 이름, 뒤는 프로바이더에서 제공하는 리소스 유형을 의미
  - local_file -> local 프로바이더에 속한 리소스 유형 따라서 해당 유형이 어떤 프로바이더가 제공하는 것인지는 앞의 이름으로 확인 가능
- 리소스 유형이 선언되면 뒤에는 고유한 이름이 붙음. 이름은 동일한 유형에 대해 식별자 역할을 하기 때문에 유형이 같은 경우에는 같은 이름을 사용 X
- 이름 뒤에는 리소스 유형에 대한 구성 인수들이 중괄호 내에 선언. 유형에 인수가 필요하지 않은 경우도 있지만, 그 경우에도 중괄호는 입력 O

```
resource "<리소스 유형>" "<이름>" {
  <인수>  = <값>
}

resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}
```

- 리소스에서 사용되는 유형들은 프로바이더에 종속성을 갖는다.
- 특정 프로바이더의 유형만 추가해도 terraform init을 수행하면 해당 프로바이더 설치

```
➜  03.start git:(main) ✗ terraform init
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/local from the dependency lock file
- Finding latest version of hashicorp/aws...
- Installing hashicorp/local v2.6.1...
- Installed hashicorp/local v2.6.1 (signed by HashiCorp)
- Installing hashicorp/aws v6.24.0...
- Installed hashicorp/aws v6.24.0 (signed by HashiCorp)
Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.
```

- aws 프로바이더가 설치되는 것을 확인 가능
- 프로바이더에 따라 접속 정보, 필수 인수를 선언해야 하는 경우가 있으므로 일반적으로는 프로바이더 구성과 함께 사용해야 함.
  - depends_on : 종속성 선언, 선언된 구성 요소와의 생성 시점에 대해 정의
  - count : 선언된 개수에 따라 여러 리소스 생성
  - for_each : map 또는 set 타입의 데이터 배열의 값을 기준으로 여러 리소스 생성
  - provider : 동일한 프로바이더 다수 정의되어 있는 경우 지정
  - liftcycle : 리소스의 수명주기 관리
  - prosivioner : 리소스 생성 후 추가 작업 정의
  - timeouts : 프로바이더에서 정의한 일부 리소스 유형에서는 create, update, delete에 대한 허용 시간을 정의 기능

#### 3.4.2 종속성

> 테라폼의 종속성은 resource, module 선언으로 프로비저닝 되는 각 요소의 생성 순서를 구분짓는다.

- 기본적으로 다른 리소스에서 값을 참조해 불러올 경우 생성 선후 관계에 따라 작업자가 의도하지 않아도 자동으로 연관관계가 정의되는 암시적 종속성을 갖게 됨
- 강제로 리소스 간 명시적 종속성을 부여할 경우 메타인수인 depends_on을 활용한다.

```
resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}

resource "local_file" "def" {
  content  = "def!"
  filename = "${path.module}/def.txt"
}
```

> 두 리소스 구성 요소는 서로 선후관계가 없는 동일한 수준이므로 테라폼의 병렬 실행 방식에 따라 terraform apply를 수행하면 동시 수행

```
resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}

resource "local_file" "def" {
  content  = local_file.abc.content # <- local_file.abc의 속성 값을 대신 넣어줌
  filename = "${path.module}/def.txt"
}
```

> 두 리소스 구성에 종속성이 없는 경우에는 프로바이더에 대한 종속성만이 존재하지만, local_file.def는 local_file.abc의 값을 참조해야 하므로 순서에 대해 종속이 발생함을 확인할 수 있다.

- 테라폼으로 인프라와 서비스를 프로비저닝하다 보면 리소스의 속성을 주입하지 않아도 두 리소스 간에 종속성이 필요한 경우가 있다.
- depends_on을 선언해 종속성을 강제로 적용해보자

```
resource "local_file" "abc" {
  content  = "abc!"
  filename = "${path.module}/abc.txt"
}

resource "local_file" "def" {
  depends_on = [local_file.abc]
  content  = "456"
  filename = "${path.module}/def.txt"
}
```

#### 3.4.3 리소스 속성 참조

- **인수** : 리소스 생성 시 사용자가 선언하는 값
- **속성** : 사용자가 설정하는 것은 불가능하지만 리소스 생성 이후 획득 가능한 리소스 고유 값

```Terraform
resource "<리소스 유형>" "<이름>" {
  <인수> : <값>
}

# 리소스 참조
<리소스 유형>.<이름>.<인수>
<리소스 유형>.<이름>.<속성>
```

쿠버네티스 프로바이더의 Namespace 리소스를 생성하고 그 이후 secret을 해당 Namespace에 생성하는 종속성을 리소스 인수 값으로 생성하는 예이다.
확인하려는 내용은 Namespace의 이름만 변경해도, 해당 Namespace를 참조하는 모든 리소스가 업데이트되어 영향을 받는다는 참조의 효과

```
resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }
    name = "terraform-example-namespace"
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    namespace = kubernetes_namespace.example.metadata.0.name # namespace 리소스 인수 참조
    name = "terraform-example"
  }
  data = {
    password = "P4ssw0rd"
  }
}
```

- 리소스가 생성될 때, 사용자가 입력한 '인수'를 받아 실제 리소스가 생성되면 일부 리소스는 자동으로 기본값이나 추가되는 '속성'이 부여된다.
- 각 리소스마다 문서를 확인해보면 **인수**는 *Arguments*로 표현되어 있으며 리소스 생성 후 추가되는 **속성** 값으로 *Attributes*에 안내되어 있다.
- 리소스 속성을 참조하는 다른 리소스 또는 구성 요소에서는 생성 후의 속성 값들도 인수로 가져올 수 있다.

#### 3.4.4 수명주기

> lifecycle은 리소스의 기본 수명주기를 작업자가 의도적으로 변경하는 메타인수.

- create_before_destroy (bool) : 리소스 수정 시 신규 리소스를 우선 생성하고 기존 리소스를 삭제
- prevent_destroy (bool) : 해당 리소스를 삭제(Destroy)하려 할 때 명시적으로 거부
- ignore_changes (list) : 리소스 요소에 선언된 인수의 변경 사항을 테라폼 실행 시 무시
- precondition : 리소스 요소에 선언된 이순의 조건을 검증
- postcondition : Plan과 Apply 이후의 결과를 속성 값으로 검증

#### 3.4.4.1 create_before_destroy

> 리소스 요소 특성에 따라 선언한 특정 인수 값을 수정하고 프로비저닝을 수행하면 대상을 삭제하고 다시 생성해야 되는 경우가 있을 때

> 대표적으로 클라우드 자원의 image가 변경되는 경우에는 해당 VM 리소스를 삭제하고 다시 생성됨
> 테라폼의 기본 수명주기는 삭제 후 생성이기 때문에 작업자가 의도적으로 수정된 리소스를 먼저 생성하기를 원할 수 있다.

- 예를들어, 작업자는 VM에서 동작하는 애플리케이션이 순차적으로 배포되기를 원할 수 있다.
- 이 경우 create_before_destroy가 true로 선언되면 의도한 생성을 실행한 후 삭제로 동작한다.

  > 생성되는 리소스가 기존 리소스로 인해 생성이 실패되거나 삭제 시 함께 삭제될 수 있으니 주의

  **잘못된 사례**

  1. 리소스의 명시적 구분이 사용자가 지정한 특정 이름이나 ID인 경우 기존 리소스에 할당되어 있기 때문에 생성 실패
  2. 생성 후 삭제 시 동일한 리소스에 대한 삭제 명령이 수행되어 리소스가 모두 삭제

```terraform
resource "local_file" "abc" {
  content  = "lifecycle - step 1"
  filename = "${path.module}/abc.txt"
  lifecycle {
    create_before_destroy = false
  }
}
```

`create_before_destroy`의 기본 값이 `false`이므로 작업자가 변경한 내용으로 작성된 파일을 확인할 수 있다. content의 내용을 수정하고 `create_before_destroy`를 `true`로 선언해 다시 `terraform apply`를 실행한다. 기존 `+/-` 표기와 달리 변경 대상이 되는 리소스 요소에 `+/-`가 표시된 후 삭제된다는 로그를 볼 수 있다.

```
resource "local_file" "abc" {
  content  = "lifecycle - step 2" # 수정
  filename = "${path.module}/abc.txt"
  lifecycle {
    create_before_destroy = true # 생성 후 삭제
  }
}

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:

- destroy
  +/- create replacement and then destroy
  Terraform will perform the following actions:

  # local_file.abc must be replaced
+/- resource "local_file" "abc" {
      ~ content              = "abc!" -> "lifecycle - step 1" # forces replacement
      ~ content_base64sha256 = "U+Dv8yBGJvPiVspjZXLXzN+OtaGQyd76P6VnvGOGa3Y=" -> (known after apply)
      ~ content_base64sha512 = "J873Ugx5HyDEnYsjdX8iMBjn4I3gft82udsl3lNeWEoqwmNE3mvUZNNz4QRqQ3iaT5SW1y9p3e1Xn2txEBapKg==" -> (known after apply)
      ~ content_md5          = "4edb03f55c86d5e0a76f5627fa506bbf" -> (known after apply)
      ~ content_sha1         = "5678fb68a642f3c6c8004c1bdc21e7142087287b" -> (known after apply)
      ~ content_sha256       = "53e0eff3204626f3e256ca636572d7ccdf8eb5a190c9defa3fa567bc63866b76" -> (known after apply)
      ~ content_sha512       = "27cef7520c791f20c49d8b23757f223018e7e08de07edf36b9db25de535e584a2ac26344de6bd464d373e1046a43789a4f9496d72f69dded579f6b711016a92a" -> (known after apply)
}
```

테라폼 구성에서 'content'가 변경되는 동일한 파일 이름을 지정했으므로 `1`파일 내용은 수정되지만 `2`최종적으로 삭제 시 동일한 파일을 삭제하게 되어 `3`파일이 삭제된다. `create_before_destroy`를 활성화하는 경우 작업자는 리소스의 특성을 파악해 리소스 생성과 삭제를 설계해야 함.

#### 3.4.4.2 prevent_destroy

> 작업자가 의도적으로 특정 리소스의 삭제를 방지하고 싶은 경우에 사용한다.

> main.tf -> content의 내용 수정 -> prevent_destroy를 true로 선언해 다시 terraform apply를 실행

```
resource "local_file" "abc" {
  content  = "lifecycle - step 4" # 수정
  filename = "${path.module}/abc.txt"
  lifecycle {
    prevent_destroy = true # 삭제 방지
  }
}

➜  03.start git:(main) ✗ terraform apply
local_file.abc: Refreshing state... [id=57b7d0c9d55b33110ce01703cb26078653551b59]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform planned the following actions, but then encountered a problem:

  # local_file.abc must be replaced
-/+ resource "local_file" "abc" {
      ~ content              = "lifecycle - step 3" -> "lifecycle - step 4" # forces replacement
      ... 생략
      ~ id                   = "57b7d0c9d55b33110ce01703cb26078653551b59" -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
╷
│ Error: Instance cannot be destroyed
│
│   on main.tf line 26:
│   26: resource "local_file" "abc" {
│
│ Resource local_file.abc has lifecycle.prevent_destroy set, but the plan calls for this resource to be destroyed. To avoid this error and continue
│ with the plan, either disable lifecycle.prevent_destroy or reduce the scope of the plan using the -target option.
```

#### 3.4.4.3 ignore_changes

> **ignore_changes**는 리소스 요소의 인수를 지정해 수정 계획에 변경 사항이 반영되지 않도록 하는 것이다.

> 확인을 위해 main.tf 내용을 다음과 같이 작성하고 terraform apply를 실행.

- content의 내용이 변경되었기 때문에 테라폼 실행 시 변경 계획에는 해당 인수 변경 사항이 반영된다.

```
resource "local_file" "abc" {
  content  = "lifecycle - step 5" # 수정
  filename = "${path.module}/abc.txt"
  lifecycle {
    ignore_changes = [] # 변경 무시
  }
}
resource "local_file" "abc" {
  content  = "lifecycle - step 4" # 수정
  filename = "${path.module}/abc.txt"
  lifecycle {
    ignore_changes = [content] # 변경 무시
  }
}

➜  03.start git:(main) ✗ terraform apply
local_file.abc: Refreshing state... [id=7bab27c0dcc3bd5cbc70bdbd9c75505e88a682c7]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

> 리소스 속성에 변경이 있었지만 `ignore_changes`의 대상이므로 실행 계획에 변경 사항이 포함되지 않아 아무런 변겨이 발생하지 않는다. 모든 변경 사항을 무시하고 싶다면
> `ignore_changes = all` 로 설정할 수 있다.

#### 3.4.4.4 precondition

> 리소스 생성 이전에 입력된 인수 값을 검증하는데 사용해 프로비저닝 이전에 미리 약속된 값 이외의 값 또는 필수로 명시해야 하는 인수 값을 검증할 수 있다.

- main.tf의 내용을 다음과 같이 작성하고 `terraform plan`을 실행

```
variable "file_name" {
  default = "step0.txt"
}

resource "local_file" "step6" {
  content  = "lifecycle - step 6"
  filename = "${path.module}/${var.file_name}"

  lifecycle {
    precondition {
      condition     = var.file_name == "step6.txt"
      error_message = "file_name is not \"step6.txt\""
    }
  }
}

➜  03.start git:(main) ✗ terraform plan
local_file.abc: Refreshing state... [id=7bab27c0dcc3bd5cbc70bdbd9c75505e88a682c7]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform planned the following actions, but then encountered a problem:

  # local_file.abc will be destroyed
  # (because local_file.abc is not in configuration)
  - resource "local_file" "abc" {
      - content              = "lifecycle - step 5" -> null
      ... 생략
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Error: Resource precondition failed
│
│   on main.tf line 62, in resource "local_file" "step6":
│   62:       condition     = var.file_name == "step6.txt"
│     ├────────────────
│     │ var.file_name is "step0.txt"
│
│ file_name is not "step6.txt"

```

> precondition 조건에 맞지 않는 경우 에러 발생

- `precondition`은 프로비저닝해야 하는 클라우드 인프라의 VM을 생성할 때 내부적으로 검증된 이미지 아이디를 사용하는지, 스토리지의 암호화 설정이 되어 있는지 등과 같은 구성을 미리 확인하고 사전에 잘못된 프로비저닝을 실행할 수 없도록 구성할 수 있다.

#### 3.4.4.5 postcondition

> 프로 비저닝 변경 이후 결과를 검증함과 동시에 의존성을 갖는 다른 구성의 변경을 막는 효과가 있다.

- main.tf의 내용을 다음과 같이 작성하고 terraform apply를 실행

```
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

➜  03.start git:(main) ✗ terraform apply
local_file.abc: Refreshing state... [id=7bab27c0dcc3bd5cbc70bdbd9c75505e88a682c7]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform planned the following actions, but then encountered a problem:

  # local_file.abc will be destroyed
  # (because local_file.abc is not in configuration)
  - resource "local_file" "abc" {
      - content              = "lifecycle - step 5" -> null
      - content_base64sha256 = "JX/q9SFnqmnsADrBY4DlVJ6QUD2gVbXXgMQghybEA+c=" -> null
      ... 생략
    }

  # local_file.step7 will be created
  + resource "local_file" "step7" {
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      ... 생략
      + id                   = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
╷
│ Error: Resource postcondition failed
│
│   on main.tf line 75, in resource "local_file" "step7":
│   75:       condition = self.content != ""
│     ├────────────────
│     │ self.content is ""
│
│ content cannot empty
```

> 종속성을 갖는 여러 리소스를 구성하는 경우, 리소스의 데이터가 다른 리소스 생성 시 활용될 때 원하는 속성이 정의되어야 하는 경우를 확인할 수 있다.
> 특히, 프로비저닝 이후에 생성되는 속성 값이 있으므로 영향을 받는 다른 리소스가 생성되기 전에 예상되지 않은 프로비저닝 작업을 방지할 수 있다.

- local 백엔드와 더불어 HCP Terraform, Terraform Enterprise를 대상으로 하는 cloud, 하시코프의 Key-Value 저장소를 제공하는 Consul, 대표적인 클라우드 제공 업체들의 스토리지 서비스 (S3, Azure azurermm, Google Cloud Storage, Alibaba Cloud Object Storage Service) 등이 지원된다.
- 각 백엔드 구성에 대한 설명은 테라폼 문서를 참고

### 3.5는 다음 파일에서 계속

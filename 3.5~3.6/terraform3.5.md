### 3.5 데이터 소스

> 데이터 소스는 테라폼으로 정의되지 않은 외부 리소스 또는 저장된 정보를 테라폼 내에서 참조 할 때 사용됨

#### 3.5.1 데이터 소스 구성

> 데이터 소스 블록은 data로 시작

> Resource 블록 정의와 유사

- 데이터 소스 유형은 첫 번째 언더스코어인 \_를 기준으로 앞은 프로바이더 이름, 뒤는 프로바이더에서 제공하는 리소스 유형을 의미.
- 데이터 소스 유형을 선언한 뒤에는 고유한 이름을 붙인다. 리소스의 이름과 마찬가지로 이름은 동일한 유형에 대해 식별자 역할을 하므로 중복될 수 없다.
- 이름 뒤에는 데이터 소스 유형에 대한 구성 인수들은 {} 안에 선언. 인수가 필요하지 않은 유형도 있지만, 그때에도 {}는 입력한다.

데이터 소스를 정의할 때 사용 가능한 메타인수 5가지

- **depends_on** : 종속성을 선언, 선언된 구성 요소와의 생성 시점에 대해 정의
- **count** : 선언된 개수에 따라 여러 데이터 소스를 선언
- **for_each** : map or set 타입의 데이터 배열의 값을 기준으로 여러 리소스 생성
- **provider** : 동일한 프로바이더가 다수 정의되어 있는 경우 지정
- **lifecycle** : 데이터 소스의 수명주기 관리

#### 3.5.2 데이터 소스 속성 참조

> 데이터 소스로 읽은 대상을 참조하는 방식은 리소스와 구별되게 data가 앞에 붙음.

`데이터 소스 인수의 선언과 참조 방식 예시`

```
data "<리소스 유형>" "<이름>" {
    <인수> = <값>
}

# 데이터 소스 참조
data.<리소스 유형>.<이름>.<속성>
```

> AWS 프로바이더의 가용영역을 작업자가 수동으로 입력하지 않고 프로바이더로 접근한 환경에서 제공되는 데이터 소스를 활용해 subnet의 가용영역 인수를 정의하는 예시

- 데이터 소스를 활용해 aws 프로바이더에 구성된 리전 내에서 사용 가능한 가용영역 목록을 읽을 수 있음.

```
data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_subnet" "primary" {
    availability_zone = data.aws_availability_zones.available.names[0]
    # e.g. ap-northeast-2a
}

resource "aws_subnet" "secondary" {
    availability_zone = data.aws_availability_zones.available.names[1]
    # e.g. ap-northeast-2b
}
```

```
resource "local_file" "abc" {
  content  = "123!"
  filename = "${path.module}/abc.txt"
}

data "local_file" "abc" {
  filename = local_file.abc.filename
}

resource "local_file" "def" {
  content  = data.local_file.abc.content
  filename = "${path.module}/def.txt"
}
```

`abc.txt와 def.txt 둘의 내용 같음`

- 리소스와 데이터 소스의 참조 방식을 확인한다.
- 데이터 소스 data.local_file.abc는 리소스 local_file.abc의 파일 이름을 참조해 데이터 소스를 생성.
- 데이터 소스 local_file은 읽어온 파일의 내용을 content 속성으로 참조 가능해 리소스 local_file.def에서는 data.local_file.abc.content를 참조해 def.txt 파일을 생성.

### 3.6 입력 변수

> 입력 변수는 인프라 구성하는데 필요한 속성 값을 정의해 코드의 변경 없이 여러 인프라를 생성하는데 목적

> 테라폼에선 이것을 입력 변수로 정의

입력이라는 수식어가 붙는 이유? -> terraform plan 명령어 실행 시 값을 입력하기 떄문

#### 3.6.1 변수 선언 방식

> 변수는 variable 블록에 정의. 변수 블록 뒤의 이름 값은 동일 모듈 내 모든 변수 선언에서 고유해야 하며, 이 이름으로 다른 코드 내에서 참조됨

```
변수 선언 방식 예시

variable "<이름>" {
    <인수> = <값>
}
```

변수 이름으로 사용 불가능한 이름들

- source
- version
- providers
- count
- for_each
- lifecycle
- depends_on
- locals

변수 정의 시 사용 가능한 메타인수들

- **default** : 변수의 기본값을 정의
- **type** : 변수에 허용되는 값 유형 정의
- **description** : 변수의 설명을 지정
- **validation** : 변수 선언의 제약조건을 추가해 유효성 검사 규칙을 정의
- **sensitive** : 민감한 변수 값임을 알리고 테라폼의 출력문에서 값 노출을 제한
- **nullable** : 변수의 값이 null 일 수 있음을 허용 (값이 없어도 됨)

#### 3.6.2 변수 유형

지원되는 변수의 범주와 형태는 다음과 같음

> 기본유형

    - **string** : 글의 유형
    - **number** : 숫자의 유형
    - **bool** : 불리언의 유형 (true, false)
    - **any** : 모든 유형

> 집합유형

    - **list(<유형>)** : 리스트의 유형 (인덱스 기반 집합)
    - **map(<유형>)** : 값=속성 기반 집합이며 키값 기준 정렬
    - **set(<유형>)** : 값 기반 집합이며 정렬 키값 기준 정렬
    - **tuple([<유형>, ...])**
    - **object({<인수 이름> = <유형>, ...})**

- list & set은 선언하는 형태가 비슷하지만 참조 방식이 인덱스와 키로 각각 차이가 있고
- map & set의 경우 선언된 값이 정렬되는 특징을 기억

```
variable "string" {
    type = string
    description = "var String"
    default = "myString"
}

variable "number" {
    type = number
    default = 123
}

variable "boolean" {
    default = true
}

variable "list" {
    default = ["google", "vmware", "amazon", "microsoft"]
}

output "list_index_0" {
    value = var.list.0
}

output "list_all" {
    value = [
        for name in var.list : upper(name) # 대문자로 변환
    ]
}

variable "map" { # Sorting
    default = {
        aws = "amazon"
        azure = "microsoft"
        gcp = "google"
    }
}

variable "set" { # Sorting
    type = set(string)
    default = ["google", "vmware", "amazon", "microsoft"]
}

variable "object" {
    type = object({name=string, age=number})
    default = {name="abc", age=12}
}

variable "tuple" {
    type = tuple([string, number, bool])
    default = ["abc", 123, true]
}

variable "ingress_rules" { # optional ( >= terraform 1.3.0)
    type = list(object({
        port = number,
        description = optional(string),
        protocol = optional(string, "tcp")
    }))
    default = [
        {port = 80, description = "web"},
        {port = 43, protocol = "udp"}
    ]
}

```

#### 3.6.3 유효성 검사

> 입력되는 변수 타입 지정 외에 테라폼 0.13.0 버전부터 사용자 지정 유효성 검사가 가능

- 변수 블럭 내에 `validation` 블록에서 조건인 `condition`에 지정되는 규칙이 `true` or `false`를 반환
- `error_message`는 `condition`값의 결과가 `false`인 경우 출력되는 메시지를 정의
- `regex` 함수는 대상의 문자열에 정규식을 적용하고 일치하는 문자열을 반환하는데, 여기에 `can` 함수를 함께 사용하면 정규식에 일치하지 않는 경우의 오류를 검출함
  > validation 블록은 중복으로 선언 가능

```
variable "image_id" {
    type = string
    description = "The id of the machine image (AMI) to use for the server."

    validation {
        condition = length(var.image_id) > 4
        error_message = "The image_id value must exceed 4."
    }

    validation {
        # refex(...) fails if it cannot find a match
        condition = can(regex("^ami-", var.image_id))
        error_message = "The image_id value must starting with \"ami-\"."
    }
}
```

> 조건에 대상이 되는 변수 블록 외부의 값 또한 조건으로 사용가능하여 부분적인 실행 완료 상황을 개선할 수 있음.

사용가능한 참조 값 - 입력 변수 - 로컬 변수 - 데이터 소스

유효성 검사가 필요한 입력 변수가 인수로 적용되는 리소스가 다른 입력 변수의 true/false 유무에 따라 동작해야 하는 경우를 가정한다면 다음과 같이 적용 가능

```
resource "local_file" "maybe" {
    count = var.file_create ? 1 : 0
    content = var.content
    filename = "maybe.txt"
}

variable "file_create" {
    type = bool
    default = true
}

variable "content" {
    description = "파일이 생성되는 경우에 내용이 비어있는지 확인합니다."
    type = string

    validation {
        condition = var.file_create == true ? length(var.content) > 0 : true
        error_message = "파일 내용이 비어있을 수 없습니다."
    }
}
➜  03.5.start git:(main2) ✗ terraform plan
var.content
  파일이 생성되는 경우에 내용이 비어있는지 확인합니다.

  Enter a value:

local_file.abc: Refreshing state... [id=5f30576af23a25b7f44fa7f5fdf70325ee389155]
local_file.def: Refreshing state... [id=5f30576af23a25b7f44fa7f5fdf70325ee389155]

... 생략

Plan: 0 to add, 0 to change, 2 to destroy.
╷
│ Error: Invalid value for variable
│
│   on main.tf line 54:
│   54: variable "content" {
│     ├────────────────
│     │ var.content is ""
│     │ var.file_create is true
│
│ 파일 내용이 비어있을 수 없습니다.
│
│ This was checked by the validation rule at main.tf:58,5-15.

```

> 데이터 소스를 조건으로 활용한다면 사용자가 수동으로 입력하지 않고 프로비저닝 대상이 제공하는 정보를 기반으로 유효성 검사절을 생성할 수 있음

> 허용된 인스턴스 타입 목록을 데이터 소스로부터 제공받는 경우

```
data "aws_ec2_instance_types" "valid" {
    filter {
        name = "current-generation"
        values = ["true"]
    }
    filter {
        name = "processor-info.supported-architecture"
        values = ["arm64"]
    }
}

variable "instance_type" {
    description = "The EC2 instance type to provision."
    type = string

    validation {
        condition = contains(data.aws_ec2_instance_types.valid.instance_types, var.instance_type)
        error_message = "You must select a current-generation ARM64 instance type."
    }
}
```

> 데이터 소스 읽어온 값을 변수 유효성 검사에 사용하려면 `contains` 함수를 활용해 대상 목록에 포함되어 있는지 확인해야 함

> `contains` 함수는 대상 목록에 포함되어 있는지 확인하고, 포함되어 있으면 `true`를 반환하고, 포함되어 있지 않으면 `false`를 반환

#### 3.6.4 변수 참조

> `variable`은 코드 내에서 `var.<이름>`으로 참조.
> main.tf 파일에서 변수를 참조하는 예시

```
variable "my_password" {}

resource "local_file" "abc" {
    content = var.my_password
    filename = "${path.module}/abc.txt"
}
```

#### 3.6.5 민감한 변수 취급

> `sensitive` 인수를 사용하면 변수 값이 출력되지 않음

```
variable "my_password" {
    default = "password"
    sensitive = true
}

resource "local_file" "abc" {
    content = var.my_password
    filename = "${path.module}/abc.txt"
}

 # local_file.abc must be replaced
-/+ resource "local_file" "abc" {
      # Warning: this attribute value will be marked as sensitive and will not
      # display in UI output after applying this change.
      ~ content              = (sensitive value) # forces replacement
```

`content              = (sensitive value)`

> `sensitive` 인수를 사용하면 변수 값이 출력되지 않음

#### 3.6.6 변수 입력 방식과 우선순위

> variable 목적은 코드 내용을 수정하지 않고 테라폼의 모듈적 특성을 통해 입력되는 변수로 재사용성을 높이는 데 있다.

- 특히 **입력 변수**라는 명칭에 맞게 사용자는 프로비저닝 실행시에 원하는 값으로 변수에 정의가능
- 선언되는 방식에 따라 변수의 우선순위가 있음
- 로컬 환경 -> 운영 서버 환경 정의를 다르게 할 수 있음
- 프로비저닝 파이프라인을 구성하는 경우 외부 값을 변수에 지정할 수 있음

> 변수 입력 방식과 우선순위

```
variable "my_var" {}
variable "my_var" {
    default = "var2"
}

resource "local_file" "abc" {
    content = var.my_var
    filename = "${path.module}/abc.txt"
}
```

[**우선순위 수준1**] 실행 후 입력 (변수에 값이 선언되지 않아 CLI에서 입력) :
`variable` 블록에 정의된 기본값이 없는 채로 terraform plan or terraform apply 실행 시 실행 계획 작성에 필요한 변수 값이 없으므로, 값을 입력 받음

[**우선순위 수준2**] `variable` 블록의 default 값이 있는 경우 :
`variable` 블록에 정의된 기본값이 있는 채로 terraform plan or terraform apply 실행 시 실행 계획 작성에 필요한 변수 값이 없으므로, 기본값을 사용

[**우선순위 수준3**] 환경 변수(TF_VAR\_변수 이름) :
시스템 환경 변수의 접두사에 TF_VAR\_가 포함되면 그 뒤의 문자열을 변수 이름으로 인식.

[**우선순위 수준4**] terraform.tfvars 파일에 정의된 변수 선언 :
루트 모듈의 main.tf 파일과 같은 디렉토리에 위치하는 terraform.tfvars 파일에 정의된 변수 선언이 현재까지 나온 것중 제일 우선 순의 높음

[**우선순위 수준5**] _.auto.tfvars 파일에 정의된 변수 선언 :
루트 모듈의 main.tf 파일과 같은 디렉토리에 위치하는 _.auto.tfvars 파일에 정의된 변수 선언이 현재까지 나온 것중 제일 우선 순의 높음
a.auto.tfvars 파일에 정의된 변수 선언이 현재까지 나온 것중 제일 우선 순의 높음
b.auto.tfvars 파일에 정의된 변수 선언이 현재까지 나온 것중 제일 우선 순의 높음

[**우선순위 수준6**] _.auto.tfvars.json 파일에 정의된 변수 선언 :
루트 모듈의 main.tf 파일과 같은 디렉토리에 위치하는 _.auto.tfvars.json 파일에 정의된 변수 선언이 현재까지 나온 것중 제일 우선 순의 높음

[**우선순위 수준7**] CLI 실행 시 `-var` 인수에 지정 또는 `-var-file`로 파일 지정 :

```
terraform plan -var my_var=var7
...생략...
 + content              = "var7"
...생략...

terraform plan -var my_var=var7 -var-my_var=var8
...생략...
 + content              = "var8"
...생략...
```

\*.tfvars와 같은 형식의 내용을 가진 파일이라면 -var-file로 지정할 수 있다.

### 3.7 local

> 코드 내에서 사용자가 지정한 값 또는 속성 값을 가공해 참조 가능한 local(지역 값)은 외부에서 입력되지 않고, 코드 내에서만 가공되어 동작하는 값을 선언!

- `local`은 입력 변수와 달리 선언된 모듈 내에서만 접근 가능하고 변수처럼 실행 시 입력받을 수 없다.
- 로컬은 사용자가 테라폼 코드를 구현할 때 값이나 표현식을 반복적으로 사용할 수 있는 편의를 제공
- 빈번하게 여러 곳에서 사용되는 경우 실제 값에 대한 추적이 어려워져 유지 관리 측면에서 부담이 발생할 수 있다.

#### 3.7.1 local 선언

> 로컬이 선언되는 블록은 `locals` 블록을 사용

- 선언되는 인수에 표현되는 값은 상수만이 아닌 리소스의 속성, 변수의 값들도 조합해 정의할 수 있음.
- 동일한 파일 내에서 여러 번 선언하는 것도 가능
- 여러 파일에 걸쳐 만드는 것도 가능
- local에 선언한 변수 이름은 전체 모듈 내에서 고유해야 함

```
variable "prefix" {
    default = "hello"

}

locals {
    name = "terraform"
    content = "${var.prefix} ${local.name}"
    my_info = {
        age = 20
        region = "KR"
    }
    my_nums = [1, 2, 3, 4, 5]
}

locals {
    content = "content2" # 중복 선언 -> 오류
}

.5~3.6 git:(main) ✗ terraform plan
╷
│ Error: Duplicate local value definition
│
│   on main.tf line 112, in locals:
│  112:     content = "content2" # 중복 선언 -> 오류
│
│ A local value named "content" was already defined at main.tf:103,5-44. Local value names must be unique within a module.
╵
```

#### 3.7.2 local 참조

> local 선언된 값은 `locals.<이름>`으로 참조.

- 테라폼 구성 파일을 여러개 생성해 작업하는 경우 -> 서로 다른 파일에 있더라도 다른 파일에서 참조할 수 있음.

  main.tf 파일에서 local 선언된 값을 참조하는 예시

- terraform plan을 실행 -> main.tf의 content 내용의 값으로 local.content 참조
  -> 장점이자 단점 값의 파편화로 인해 유지 보수가 어려워질 수 있음

```/main.tf
resource "local_file" "abc" {
variable "prefix" {
    default = "hello"

}

locals {
    name = "terraform"
}

resource "local_file" "abc" {
    content = local.content
    filename = "${path.module}/abc.txt"
}

sub.tf 파일에서 local 선언된 값을 참조하는 예시

/sub.tf
locals {
    content = "{$var.prefix} ${local.name}"
}
```

### 3.8 출력

> 출력은 테라폼 코드 내에서 프로비저닝 수행 후의 결과 속성 값을 확인하는 용도로 사용

- 코드 내 요소 간에 제한된 노출을 지원하듯 테라폼 모듈 간, 워크스페이스 간 데이터 접근 요소로도 활욜할 수 있다. - 루트 모듈에서 사용자가 확인하고자 하는 특정 속성 출력 - 자식 모듈의 특정 값을 정의하고 루트 모듈에서 결과를 참조 - 서로 다른 루트 모듈의 결과를 원격으로 읽기 위한 접근 요소
  > 출력 값을 작성하면 단순한 디버깅을 넘어 속성 값을 노출하고 접근할 수 있음

#### 3.8.1 output 선언

> output 선언은 `output` 블록을 사용

```
output "instance_ip_addr" {
    value = "http://${aws_instance.web.private_ip}"
}
```

> 출력되는 값은 value 값이며 테라폼이 제공하는 조합과 프로그래밍적인 기능들에 의해 원하는 값을 출력할 수 있음

- 주의할 점 : output 결과에서 리소스 생성 후 결정되는 속성 값은 프로비저닝이 완료 되어야 최종적으로 결과를 확인할 수 있고 `terraform plan` 단계에서는 적용될 값을 출력하기 않는다.
  output 정의 시 사용 가능한 메타인수
- description : 출력 값에 대한 설명
- sensitive : 출력 값을 민감한 정보로 간주하고 출력하지 않음
- depends_on : value에 담길 값이 특정 구성에 종속성이 있는 경우 생성되는 순서를 임의로 조정
- precondition : 출력 전에 지정된 조건을 검증
  > `sensitive` -> 디버깅 목적보다는 값을 노출시키지 않고 상위 모듈 또는 다른 모듈에 참조하기 위한 목적

#### 3.8.2 output 활용

```
resource "local_file" "abc" {
    content = "abc123"
    filename = "${path.module}/abc.txt"
}

output "file_id" {
    value = local_file.abc.id
}

output "file_abspath" {
    value = abspath(local_file.abc.filename)
}

... 생략 ...
Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + file_abspath = "/Users/hwangbongsu/Desktop/terraform/3.5~3.6/abc.txt"
  + file_id      = (known after apply)
```

- 이미 정해진 속성에 대해서는 출력 가능 -> 아직 생성되지 않은 file_id 같은 값의 경우에는 결과 예측 불가 -> `terraform apply` 실행 시 결과 값으로 출력

```
terraform apply

... 생략 ...
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

file_abspath = "/Users/hwangbongsu/Desktop/terraform/3.5~3.6/abc.txt"
file_id = "6367c48dd193d56ea7b0baad25b19455e529f5ee"
```

- apply 실행 이후 구성 재적용 없이 마지막 결과로 표기되는 output 을 다시 확인하고 싶은경우 `terraform output` 명령어 사용

### 3.9 반복문

> list 형태의 값 목록이나 Key-Value 형태의 문자열 집합인 데이터가 있는 경우 동일한 내용에 대해 테라폼 구성 정의를 반복적으로 하지 않고 관리 가능!

#### 3.9.1 count

> 리소스 또는 모듈 블록에서 count 값이 정수인 인수가 포함된 경우 선언된 정수 값만큼 리소스나 모듈을 생성

- `count` 에서 생성되는 참조값은 `count.index`, 반복하는 경우 0부터 + 1씩 증가해 인덱스가 부여됨

```
resource "local_file" "abc" {
    count = 5
    content = "abc"
    filename = "${path.module}/abc.txt"
}
```

> 의도대로라면 파일 5개 생성 -> 파일명 변함 없기에 결과적으론 하나의 파일 존재

- count를 사용하는 경우 반복되는 정의로 인해 문제되는 값이 있는지 주의

```
resource "local_file" "abc" {
    count = 5
    content = "abc"
    filename = "${path.module}/abc${count.index}.txt"
}
```

> 때때로 여러 리소스나 모듈의 count로 지정되는 수량이 동일해야 하는 상황 존재 -> 이 경우 count에 부여되는 정수 값을 외부 변수에 식별되도록 구성할 수 있다.

```
 variable "names" {
    type = list(string)
    default = ["a", "b", "c"]
 }

resource "local_file" "abc" {
    count = length(var.names)
    content = "abc"
    filename = "${path.module}/abc-${var.names[count.index]}.txt"
}

resource "local_file" "def" {
    count = length(var.names)
    content = local_file.abc[count.index].content
    filename = "${path.module}/def-${element(var.names, count.index)}.txt"
}
```

> `local_file.abc`와 `local_file.def`는 var.names에 선언되는 값에 영향을 받아 동일한 개수 만큼 생성 X

- `local_file.def`의 경우 `local_file.abc`와 개수가 같아야 content에 선언되는 인수 값에 오류가 없을 것
- `count`로 생성되는 리소스의 경우 `<리소스 타입>.<이름>[<인덱스 번호>]`, 모듈의 경우 `module.<모듈 이름>[<인덱스 번호>]`으로 참조 가능
  -> 단 `module`내에 `count` 적용이 불가능한 선언이 있으므로 주의

#### 3.9.2 for_each

> 리소스 또는 모듈 블록에서 for_each 값이 map 또는 set 이면, 선언된 key 값 개수만큼 리소스르 생성하게 됨

```
resource "local_file" "abc" {
    for_each = {
        a = "content a"
        b = "content b"

    }
    content = each.value
    filename = "${path.module}/${each.key}.txt"
}
```

> `for_each` 블록 -> `each` 속성을 사용해 구성을 수정할 수 있음

- each.key : 이 인스턴스에 해당하는 map 타입의 key 값
- each.value : 이 인스턴스에 해당하는 map 타입의 value 값

- 생성되는 리소스의 경우 <리소스 타입>.<이름>[<key>]
- 모듈의 경우 module.<모듈 이름>[<key>]으로 해당 리소스의 값을 참조 가능
  이 참조 방식을 통해 리소스 간 종속성을 정의하기도 하고 변수로 다른 리소스에서 사용하거나 출력을 위한 결과 값으로 사용한다.

```
variable "names" {
    default = {
        a = "content a"
        b = "content b"
        c = "content c"
    }
}
resource "local_file" "abc" {
    for_each = var.names
    content = each.value
    filename = "${path.module}/abc-${each.key}.txt"
}

resource "local_file" "def" {
    for_each = local_file.abc
    content = each.value.content
    filename = "${path.module}/def-${each.key}.txt"
}

variable "names" {
    default = {
        a = "content a"
        c = "content c"
    }
}
resource "local_file" "abc" {
    for_each = var.names
    content = each.value
    filename = "${path.module}/abc-${each.key}.txt"
}

resource "local_file" "def" {
    content = each.value.content
    for_each = local_file.abc
    filename = "${path.module}/def-${each.key}.txt"
}
local_file.def["b"]: Destroying... [id=eae49f039c8416479f1c63b883f96fc39fe3d7c6]
local_file.def["b"]: Destruction complete after 0s
local_file.abc["b"]: Destroying... [id=eae49f039c8416479f1c63b883f96fc39fe3d7c6]
local_file.abc["b"]: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 2 destroyed.
```

> key값은 count의 index와 달리 고유하므로 중간에 값을 삭제한 후 다시 적용해도 삭제한 값에 대해서만 리소스를 삭제함.

- key에 해당하는 리소스만 영향을 받아 삭제됨
- 인덱스에 영향을 바디 않도록 구성한다면 list대신 set을 활요해 작성함으로써 중간 값의 삭제로 인해 다른 리소스가 삭제되는 것을 방지 가능

```
resource "local_file" "abc" {
    for_each = toset(["a", "b", "c"])
    content = "abc"
    filename = "${path.module}/abc-${each.key}.txt"
}
```

#### 3.9.3 for

> for 문은 복합 형식 값의 형태를 변환하는데 사용된다.

- ex) list 값의 포맷을 변경하거나 특정 접두사를 추가할 수 있고, output에 원하는 형태로 반복적인 결과를 표현할 수 있다.

  - `list` 타입의 경우 `값` 또는 `인덱스`와 `값`을 반환
  - `map` 타입의 경우 `key`또는 `key`와 `값`에 대해 반환
  - `set` 타입의 경우 `key` `값`에 대해 반환

```
variable "names" {
    default = ["a", "b", "c"]

}

# resource "local_file" "abc" {
#     content = jsonencode(var.names)
#     filename = "${path.module}/abc.txt"
# }
resource "local_file" "abc" {
    content = jsonencode([for s in var.names : upper(s)])
    filename = "${path.module}/abc.txt"
}
```

> for 구문 규칙

- `list` 유형의 경우 반환 받는 값이 하나로 되어 있으면 값을, 두 개인 경우 앞의 인수가 인덱스를 반환하고 뒤의 인수가 값을 반환 (관용적으로 인덱슨느 i, 값은 v로)
- `map` 유형의 경우 반환 받는 값이 하나로 되어 있으면 키를 두 개인 경우 앞의 인수가 키를 반환하고 뒤에 인수가 값을 반환 (관용적으로 키는 k, 값은 v로)
- 결과 값은 `for` 문을 묶는 기호가 [] 인 경우 tuple로 반환되고 {} 인 경우 object로 형태로 반환
- object 형태의 경우 키와 값에 대한 쌍은 => 기호로 구분
- {} 형식을 사용해 object 형태로 결과를 반환하는 경우 키 값은 고유해야 하므로 값 뒤에 그룹화 모드 심볼 (...)를 붙여서 키의 중복을 방지
- if 구문을 추가해 조건 부여 가능

```
variable "names" {
  type = list(string)
  default = ["a", "b"]
}

output "A_upper_value" {
    value = [for s in var.names : upper(s)]
}

output "B_index_and_value" {
    value = [for i, v in var.names: "${i} => ${v}"]
}

output "C_make_objcet" {
    value = {for s in var.names : s => upper(s)}
}

output "D_with_filter" {
    value = [for v in var.names: upper(v) if v!= "a"]
}

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
Outputs:
A_upper_value = [
  "A",
  "B",
]
B_index_and_value = [
  "0 => a",
  "1 => b",
]
C_make_objcet = {
  "a" = "A"
  "b" = "B"
}
D_with_filter = [
  "B",
]
```

> map 유형에 대한 for 구문 처리의 몇 가지 예를 확인하기 위해 다음과 같이 main.tf 파일을 수정

```
variable "members" {
    type = map(object({
        role = string
    }))
    default = {
        ab = {role = "member", group = "dev"}
        cd = {role = "admin", group = "dev"}
        ef = {role = "member", group = "obs"}
    }
}

output "A_to_tuple" {
    value = [for k, v in var.members : "${k} is ${v.role}"]
}

output "B_get_only_role" {
    value = {
        for name, user in var.members: name => user.role
        if user.role == "admin"
    }
}

output "C_group" {
    value = {
        for name, user in var.members: user.role => name...
    }
}
A_to_tuple = [
  "ab is member",
  "cd is admin",
  "ef is member",
]
B_get_only_role = {
  "cd" = "admin"
}
C_group = {
  "admin" = [
    "cd",
  ]
  "member" = [
    "ab",
    "ef",
  ]
}
```

#### 3.9.4 dynamic

> 리소스 같은 테라폼 구성을 작성하다 보면 `count` or `for_each` 속성을 사용해 리소스 전체를 여러 개 생성하는 것 외에도 리소스 내에 선언되는 구성 블록을 다중으로 작성해야 하는 경우

> ex) aws_instance 리소스의 경우 인스턴스 생성 시 여러 개의 보안 그룹을 지정해야 하는 경우
> AWS의 security_group 리소스 구성에 ingress, egress 요소가 리소스 선언 내부에서 블록 형태로 여러 번 정의되는 경우

```
resource "aws_security_group" "allow_tls" {
    name = "allow_tls"
    description = "Allow TLS inbound traffic"
    ingress {
        description = "TLS from VPC"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [aws_vpc.main.cibr_block]
        ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    }
    ingress {
        description = "HTTP"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [aws_vpc.main.cibr_block]
        ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "allow_tls"
    }
}
```

> resource 내의 블록 속성은 리소스 자체의 반복 선언이 아닌 내부 속성 요소 중 블록으로 표현되는 부분에 대해서만 반복 구문을 사용해야 하므로, 이때 dynamic 블록을 사용해 동적인 블록을 생성가능

- 기존 블록의 속성 이름을 dynamic 블록의 이름으로 선언하고 기존 블록 속성에 정의되는 내용을 content 블록에 작성한다. 반복 선언에 사용되는 반복문 구문은 for_each를 사용한다.
- 기존 for_each 적용 시 속성에 key, value가 적용 되었다면 dynamic에서는 dynamic에 지정한 이름에 대해 속성이 부여됨

```
# 일반적인 블록 속성 반복 적용
resource "provider_resource" "name" {
    name = "some_resource"

    some_setting = {
        key = a_value
    }
    some_setting = {
        key = b_value
    }
    some_setting = {
        key = c_value
    }
    some_setting = {
        key = d_value
    }
}

# dynamic 블록 적용
resource "provider_resource" "name" {
    name = "some_resource"

    dynamic "some_setting" {
        for_each = {
            a_key = a_value
            b_key = b_value
            c_key = c_value
            d_key = d_value
        }
        content {
            key = some_setting.value
        }
    }
}
```

- archive 프로바이더의 archive_file에 source 블록 선언을 반복하는 경우 terraform apply를 수행해 확인해본다.
  > 새로운 프로바이더가 추가되는 경우 terraform init 명령어를 실행해 프로바이더를 설치한다.

```
data "archive_file" "dotfiles" {
    type = "zip"
    output_path = "${path.module}/dotfiles.zip"
    source {
        content = "hello a"
        filename = "${path.module}/a.txt"
    }
    source {
        content = "hello b"
        filename = "${path.module}/b.txt"
    }
    source {
        content = "hello c"
        filename = "${path.module}/c.txt"
    }
}
```

```

variable "names" {
    default = {
        a = "hello d"
        b = "hello f"
        c = "hello g"
    }
}

data "archive_file" "dotfiles" {
    type = "zip"
    output_path = "${path.module}/dotfiles.zip"

    dynamic "source" {
        for_each = var.names
        content {
            content = source.value
            filename = "${path.module}/${source.key}.txt"
        }
    }
}
```

### 3.10 조건식

> 테라폼에서는 조건식은 3항 연산자 형태를 갖는다.

- 조건은 `true` or `false`로 확인 되는 모든 표현식을 사용 가능
- 비교, 논리 연산자를 사용해 조건을 확인
- 조건식은 ? 기호를 기준으로 왼쪽이 조건, 오른쪽은 : 기호를 기준으로 왼쪽이 조건에 대한 `true`인 경우 왼쪽 값, `false`인 경우 오른쪽 값을 반환

```
var.a != "" ? var.a : "default-a"
```

- > var.example ? 12 : "hello" -> 비권장
- > var.example ? "12" : "hello" -> 권장
- > var.example ? tostring(12) : "hello" -> 권장

> 조건식은 단순히 특정 속성에 대한 정의, 로컬 변수에 대한 재정의, 출력 값에 대한 조건 정의 뿐만 아니라 리소스 생성 여부에 응용 가능

> `count`에 조건식을 결합한 겨웅 다음과 같이 특정 조건에 따라 리소스 생성 여부를 선택 가능

```
variable "enable_file" {
    default = true
}

resource "local_file" "foo" {
    count = var.enable_file ? 4 : 0
    content = "foo!"
    filename = "${path.module}/foo.bar"
}
output "content" {
    value = var.enable_file ? local_file.foo[0].content : "123"
}

```

### 3.11 함수

> 테라폼은 프로그래밍 언어적인 특성을 갖추고 있는데, 값의 유형을 변경하거나 조합할 수 있는 내장 함수들이 그 예시다.

- 단, 내장된 함수 외에 사용자가 구현하는 별도의 사용자 정의 함수를 지원하지 않는다. 함수 종류에는 숫자, 문자열, 컬렉션, 인코딩, 파일 시스템, 날짜/시간, 해시/암호화, IP 네트워크, 유형변환 등이 있다.
- 테라폼 코드에 함수 적용 시 -> 변수, 리소스 속성, 데이터 소스 속성, 출력 값 표현 시 작업을 동적이고 효과적으로 수행할 수 있음.
- 단순 함수을 위해 `terraform apply`는 비효율적 -> `terraform console` 명령어를 사용해 테라폼 콘솔에서 함수 테스트 가능

> 간단한 예시로 설명 했지만 함수는 인자값, 결과, 출력이 정형화 되어 코드를 작성할 때 사용하면 사용자의 실수를 방지하고, 코드의 재사용성을 높이며, 유지 보수를 용이하게 한다.

> Terraform 함수 사용시의 장점

- 정확성 : 함수는 특정 작업을 수행하는 코드 블록을 여러 번 재사용할 수 있어 동일한 작업을 반복적으로 작성하는 과정에서 발생 가능한 실수를 줄일 수 있음
- 효율성 : 함수는 코드의 재사용성을 높여 동일한 기능을 여러 곳에서 필요로 할 때 함수를 호출하기만 되므로 개발 시간이 절약
- 가독성 : 함수의 코든느 구조를 체계적으로 만들어주어 코드의 가독성을 높이고 유지 보수를 용이하게 한다.

### 3.12 프로비저너

> 프로비저너는 프로바이더와 비슷하게 `제공자`로 해석되는데 프로바이더로 실행되지 않는 커맨드와 파일 복사 같은 역할을 수행한다.

- ex) 클라우드에 리눅스 vm을 생성하는 것에 더해 특정 패키지를 설치해야 하거나 파일을 생성해야 하는 경우, 이것들은 테라폼의 구성과 별개로 동작해야 함.
- 프로비저너로 실행된 결과는 테라폼의 상태 파일과 동기화되지 않으므로 프로비저닝에 대한 결과가 항상 같다고 보장할 수 없다.
- 따라서 프로비저너 사용을 최소화 하는 것이 좋다.
  종류 - file, local-exec, remote-exec

#### 3.12.1 프로비저너 사용 방법

> 프로비저너의 경우 리소스 프로비저너 이후 동작하도록 구성할 수 있다.

ex) AWS의 EC2 인스턴스를 생성하고 난 후 CLI를 통해 별도 작업을 수행하는 상황을 가정할 수 있다.

```
variable "sensitive_content" {
  default   = "secret"
  sensitive = true
}
resource "local_file" "foo" {
  content  = upper(var.sensitive_content)
  filename = "${path.module}/foo.bar"

  provisioner "local-exec" {
    command = "echo The content is ${self.content}"
  }

  provisioner "local-exec" {
    command    = "abc"
    on_failure = continue
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo The deleting filename is ${self.filename}"
  }
}
```

```
local_file.foo: Creating...
local_file.foo: Provisioning with 'local-exec'...
local_file.foo (local-exec): (output suppressed due to sensitive value in config)
local_file.foo (local-exec): (output suppressed due to sensitive value in config)
local_file.foo: Provisioning with 'local-exec'...
local_file.foo (local-exec): Executing: ["/bin/sh" "-c" "abc"]
local_file.foo (local-exec): /bin/sh: abc: command not found
local_file.foo: Creation complete after 0s [id=3c3b274d119ff5a5ec6c1e215c1cb794d9973ac1]
```

> 프로비저너는 선언된 리소스 블록의 작업이 종료되고 나서 지정한 동작을 수행

- 작성된 예제에서와 같이 다수의 `프로비저너`를 반복적으로 사용할 수 있다.
- 이 값들은 순서대로 처리된다.

> `프로비저너`에서는 `self` 값에 대한 참조 가능

- 리소스 `프로비저닝` 작업 후에 해당 속성 값들을 참조할 수 있다.
- 예제에서는 `content`값을 가져오도록 처리함.

  > `프로비저너`의 동작은 실행 계획만으로는 그 결과를 유추할 수 없다.
  > 실제 terraform apply 명령어를 실행해 보면 `프로비저너`에 관련한 메시지는 보이지 않는다.

`프로비저너`선언 순서에 따라
첫 번째. `Provisioning with 'local-exec'`... message는 `content`를 출력하려는 의도
하지만 `output suppressed due to sensitive value in config` message와 함께 원하는 출력이 보이지 않는다.
이것은 local_file의 content에 지정한 var.sensitive_content 값이 sensitive 속성을 갖고 있기 때문에 출력되지 않는다.

> `terraform`은 연관된 `프로비저너`에서의 출력 또한 민감하다고 판단해 화면에 출력하지 않는다.

두 번째. `프로비저너`에서는 abc라는 커맨드를 수행한다. 대부분의 작업 환경에서 이러한 커맨드는 없을 것이므로 이 단계에서 Apply 동작은 실패해야 함.
하지만 `on_failure = continue` 선언이 있기에 실패 시에도 다음 단계로 넘어감.
-> `on_failure = continue` 주석 -> 실패

```
│ Error: local-exec provisioner error
│
│   with local_file.foo,
│   on main.tf line 435, in resource "local_file" "foo":
│  435:   provisioner "local-exec" {
│
│ Error running command 'abc': exit status 127. Output: /bin/sh: abc: command not found
│
```

세 번째. `프로비저너`에 대해서는 `terraform apply`를 실행했을 때 관한 출력을 찾을 수 없다.
`when = destroy` 속성이 추가된 `프로비저너`는 terraform destroy를 수행할 때에만 정보를 출력함

`terraform destroy` 명령어를 실행해 확인해본다.

```
local_file.foo: Destroying... [id=3c3b274d119ff5a5ec6c1e215c1cb794d9973ac1]
local_file.foo: Provisioning with 'local-exec'...
local_file.foo (local-exec): Executing: ["/bin/sh" "-c" "echo The deleting filename is ./foo.bar"]
local_file.foo (local-exec): The deleting filename is ./foo.bar
local_file.foo: Destruction complete after 0s

```

의도한 `프로비저너`의 결과가 표기되는 것을 확인할 수 있다.

> 일부 작업에서 리소스 제거에 대한 처리가 필요한 경우 `terraform destroy` 명령어를 실행했을 때 동작하는 `프로비저너`를 활용할 수 있다.

> 프로비저너의 속성에 대한 종류

- command : 실행할 명령어
- on_failure : 명령어 실행 실패 시 처리 방법
- when : 프로비저너 실행 시점

> `on_failure` 속성에 대한 종류

- continue : 실행 실패 시 계속 진행
- fail : 실행 실패 시 중단

#### 3.12.2 local_exec 프로비저너

> local_exec -> 테라폼이 실행되는 환경에서 수행할 커맨드를 정의한다.
> 운영체제에 맞게 테라폼 실행하는 환경에 맞는 커맨드를 정의해야함.

- `command(필수)` : 실행할 명령줄을 입력하며 << 연산자를 통해 여러 줄의 커맨드 입력 가능
- `working_dir(선택)` : `command` 명령을 실행할 디렉토리를 지정해야 하고 상대/절대 경로로 설정
- `interpreter(선택)` : 명령을 실행하는 데 필요한 인터프리터를 지정하며, 첫 번째 인수는 인터프리터 이름이고 두 번째부터가 인터프리터 인수 값
- `environment(선택)` : 실행 시 환경 변수는 실행 환경의 값을 상속 받으며, 추가 또는 재할당하려는 경우 해당 인수에 key = value 형태로 설정

```

# Unix/Linux/MacOs
resource "null_resource" "example1" {
    provisioner "local-exec" {
        command = <<EOF
        echo Hello!! > file.txt
        echo $ENV >> file.txt
        EOF
        interpreter = ["bash", "-c"]

        working_dir = "/tmp"

        environment = {
            ENV = "world!"
        }
    }
}

# Windows
resource "null_resource" "example2" {
    provisioner "local-exec" {
        command = <<EOF
        Hello!! > file.txt
        Get-ChildItem Env:ENV >> file.txt
        EOF
        interpreter = ["powershell", "-command"]
        working_dir = "C:\\windows\\temp"
        environment = {
            ENV = "world!"
        }
    }
}
```

> `command`의 << 연산자를 통해 다중 라인의 명령을 수행하며 각 환경에 맞는 인터프리터를 지정해 해당 명령을 수행함.

> `Apply` 수행 시 이 명령의 실행 위치를 `working_dir`를 사용해 지정하고 `command`에서 사용하는 환경 변수에 대해 `environment`에서 지정한다.

> `Apply` 수행하면 `working_dir`위치의 file.txt에 기독된 내용 확인 가능

#### 3.12.3 원격지 연결

> `remote-exec`와 file `프로비저너`를 사용하기 위해서는 원격지에 연결한 SSH, WinRM 연결 정의가 필요

```
resource "null_resource" "example1" {
    connection {
        type = "ssh"
        user = "root"
        password = var.root_password
        host = var.host
    }

    provisioner "file" {
        source = "conf/myapp.conf"
        destination = "/etc/myapp.conf"
    }

    provisioner "file" {
        source = "conf/myapp.conf"
        destination = "C:/App/myapp.conf"

        connection {
          type = "winrm"
          user = "Administrator"
          password = var.admin_password
          host = var.host
        }
    }
}

```

> `connection` 블록은 리소스에 선언되는 경우 해당 리소스내에 구성된 `프로비저너`에 대해 공통으로 선언되고, `프로비저너` 내에 선언되는 경우 해당 프로비저너에만 적용된다.

적용되는 인수

- <인수> : <설명>(<연결 타입>) - 기본값 <기본값내용>
- type : 연결 유형(ssh, winrm) - 기본값 ssh
- user : 연결에 사용되는 사용자 (ssh, winrm) - 기본값 ssh: root, winrm: Administrator
- password : 연결에 사용되는 비밀번호 (ssh, winrm) - 기본값
- host : 연결에 사용되는 호스트 주소 (ssh, winrm) - 기본값
- port : 연결 대상의 타입별 사용 포트 번호 (ssh, winrm) - 기본값 ssh: 22, winrm: 5985
- timeout : 연결 시도에 대한 대기 값 타임아웃 시간 (ssh, winrm) - 기본값 5m
- script_path : 스크립트 복제 시 생성되는 경로 (ssh, winrm) - 기본값 별도 설명
- private_key : 연결 시 사용할 SSH key를 지정하며 password 인수보다 우선 적용 (ssh)
- certificate : 서명된 CA인증서로 사용 시 private_key와 함께 사용 (ssh)
- agent : ssh-agent를 사용해 인증하지 않는 경우 false로 설정하며 Windows의 경우 Pafeant만 사용가능 (ssh)
- agent_identity : 인증을 위한 ssh-agent의 기본 사용자 (ssh)
- host_key : 원격 호스트 또는 서명된 CA의 연결을 확인 하는 데 사용되는 공개 키 (ssh)
- target_platform : 연결 대상 플랫폼으로 windows, unix (ssh) - 기본값 unix
- https : true인 경우 HTTPS로 연결 (winrm) - 기본값 false
- insecure : true인 경우 인증서 검증 없이 연결 (winrm) - 기본값 false
- use_ntlm : true인 경우 NTLM 인증 사용 (winrm) - 기본값 false
- cacert : 유효성 검증을 위한 CA 인증서 (winrm) - 기본값

> 원격 연결이 요구되는 `프로비저너`의 경우 스크립트 파일을 원결 시스템에 업로드해 해당 시스템의 기본 쉘에서 실행하도록 하므로 `script_path`의 경우 적절한 위치를 지정하도록 한다. 경로는 난수인 `%RAND%` 경로가 포함되어 생성된다.

- Unix/Linux/MacOs : `/tmp/terraform_%RAND%.sh`
- windows(cmd) : `C:\windows\temp\terraform_%RAND%.cmd`
- windows(powershell) : `c:\windows\temp\terraform_%RAND%.ps1`

- 베스천 로스트를 통해 연결하는 경우 관련 인수를 지원한다.
- bastion_host : 설정하게 되면 베스천 호스트 연결이 활성화되며, 연결 대상 호스트를 지정
- bastion_host_key : 호스트 연결을 위한 공개키
- bastion_port : 베스천 호스트 연결을 위한 포트 - 기본값 port 인수값
- bastion_user : 베스천 호스트 연결을 위한 사용자 - 기본값 user 인수값
- bastion_password : 베스천 호스트 연결을 위한 비밀번호 - 기본값 password 인수값
- bastion_private_key : 베스천 호스트 연결을 위한 SSH key - 기본값 private_key 인수값
- bastion_certificate : 서명된 CA 인증서 내용으로 bastion_private_key와 함께 사용

#### 3.12.4 file 프로비저너

> file 프로비저너는 테라폼 실행하는 시스템에서 연결 대상으로 파일 또는 디렉토리를 복사하는데 사용됨

사용되는 인수

- source : 소스 파일 또는 디렉토리로, 현재 작업 중인 디렉토리에 대한 상대 경로 또는 절대 경로로 지정할 수 있다. content와 함께 사용할 수 없다.
- content : 연결 대상에 복사할 내용을 정의하며 대상이 디렉토리인 경우 `tf-file-content` 파일이 생성되고, 파일인 경우 해당 파일에 내용이 기록된다. source와 함께 사용할 수 없음
- destination : 필수 항목으로 항상 절대 경로로 지정되어야 하며, 파일 또는 디렉토리다.

> `destination` 지정 시 주의해야 할 점은 ssh 연결의 경우 대상 디렉토리가 존재해야 하며, winrm 연결은 디렉터리가 없는 경우 자동으로 생성한다는 것!!

> 디렉토리를 대상으로 한다면 `source` 경로 형태에 따라 동작에 차이가 생김. `destination`이 `/tmp`일 때 `source`가 디렉터리로 `/foo` 처럼 마지막에
> `/`가 없는 경우 대상 디렉토리에 지정한 디렉토리가 업로드되어 연결된 시스템에 `/tmp/foo` 경로로 생성된다.
> `source`가 디렉토리로 `/foo/` 처럼 마지막에 `/`가 있는 경우 `source`디렉토리 내의 파일만 `/tmp 디렉터리에 업로드 된다.

ex) file 프로비저너와 관련한 예시 코드

```
resource "null_resource" "foo" {
    # myapp.conf 파일이 /etc/myapp.conf 로 업로드
    provisioner "file" {
        source = "conf/myapp.conf"
        destination = "/etc/myapp.conf"
    }

    #content의 내용이 /tmp/file.log 파일로 생성
    provisioner "file" {
        content = "ami used : ${self.ami}"
        destination = "/tmp/file.log"
    }

    # configs.d 디렉토리가 /etc/configs.d 로 업로드
    provisioner "file" {
        source = "conf/configs.d/"
        destination = "/etc"
    }
    # apps/app1 디렉토리 내의 파일들만 D:/IIS/webapp1 디렉토리 내에 업로드
    provisioner "file" {
        source = "apps/app1/"
        destination = "D:/IIS/webapp1"
    }
}
```

#### 3.12.5 remote-exec 프로비저너

> `remote-exec`는 원격지 환경에서 실행할 커맨드와 스크립트를 정의함
> 예를들어. AWS의 EC2 인스턴스를 생성하고 해당 vm에서 명령을 실행하고 패키지를 설치하는 등의 동작을 의미
> 사용되는 인수는 다음과 같고 각 인수는 서로 배타적이다.

- inline : 명령에 대한 목록으로 [ ] 블록 내에 " " 로 묶인 다수의 명령을 ,로 구분해 구성
- script : 로컬의 스크립트 경로를 넣고 원격에 복사해 실행한다.
- scripts : 로컬의 스크립트 경로의 목록으로 [ ] 블록 내에 " " 로 묶은 다수의 스크립트 경로를 ,로 구분해 구성

`script` 또는 `scripts` 의 대상 스크립트 실행에 필요한 인수는 관련 구성에서 선언할 수 없으므로 필요할 때 file 프로바이더로 해당 스크립트를 업로드하고 inline 인수를 활용해 스크립트에 인수를 추가한다.

```
resource "aws_instance" "web" {
    # ...

    connection {
        type = "ssh"
        user = "root"
        password = var.root_password
        host = self.public_ip
    }

    provisioner "file" {
        source = "script.sh"
        destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/script.sh",
            "/tmp/script.sh args",
        ]
    }
}
```

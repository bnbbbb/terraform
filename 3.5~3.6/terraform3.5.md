### 3.5 데이터 소스

| 데이터 소스는 테라폼으로 정의되지 않은 외부 리소스 또는 저장된 정보를 테라폼 내에서 참조 할 때 사용됨

#### 3.5.1 데이터 소스 구성

| 데이터 소스 블록은 data로 시작

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

| 데이터 소스로 읽은 대상을 참조하는 방식은 리소스와 구별되게 data가 앞에 붙음.

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

| 입력 변수는 인프라 구성하는데 필요한 속성 값을 정의해 코드의 변경 없이 여러 인프라를 생성하는데 목적

> 테라폼에선 이것을 입력 변수로 정의

입력이라는 수식어가 붙는 이유? -> terraform plan 명령어 실행 시 값을 입력하기 떄문

#### 3.6.1 변수 선언 방식

| 변수는 variable 블록에 정의. 변수 블록 뒤의 이름 값은 동일 모듈 내 모든 변수 선언에서 고유해야 하며, 이 이름으로 다른 코드 내에서 참조됨

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

| 입력되는 변수 타입 지정 외에 테라폼 0.13.0 버전부터 사용자 지정 유효성 검사가 가능

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

| 조건에 대상이 되는 변수 블록 외부의 값 또한 조건으로 사용가능하여 부분적인 실행 완료 상황을 개선할 수 있음.

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

| 데이터 소스를 조건으로 활용한다면 사용자가 수동으로 입력하지 않고 프로비저닝 대상이 제공하는 정보를 기반으로 유효성 검사절을 생성할 수 있음

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

| 데이터 소스 읽어온 값을 변수 유효성 검사에 사용하려면 `contains` 함수를 활용해 대상 목록에 포함되어 있는지 확인해야 함

> `contains` 함수는 대상 목록에 포함되어 있는지 확인하고, 포함되어 있으면 `true`를 반환하고, 포함되어 있지 않으면 `false`를 반환

#### 3.6.4 변수 참조

| `variable`은 코드 내에서 `var.<이름>`으로 참조.
main.tf 파일에서 변수를 참조하는 예시

```
variable "my_password" {}

resource "local_file" "abc" {
    content = var.my_password
    filename = "${path.module}/abc.txt"
}
```

#### 3.6.5 민감한 변수 취급

| `sensitive` 인수를 사용하면 변수 값이 출력되지 않음

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

| variable 목적은 코드 내용을 수정하지 않고 테라폼의 모듈적 특성을 통해 입력되는 변수로 재사용성을 높이는 데 있다.

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

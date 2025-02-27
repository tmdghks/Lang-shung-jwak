(* definition for binOp *)
type binop = 
  | OpPlus   (* ~ *)
  | OpMinus  (* ; *)
  | OpTimes  (* , *)
  | OpDiv    (* @ *)


(** 표현식(expr) 정의 예시 *)
type expr =
  | EInt of int                         (* 정수 리터럴: 좍=1, 좌악=2, ... *)
  | EVar of int                         (* 변수 참조: 슝(1번 변수), 슈웅(2번 변수), 등 *)
  | EBinOp of expr * binop * expr       (* 이항 연산: ~, ;, ,, @ 에 의해 연결된 식 *)

(** 문장(statement) 정의 예시 *)
type statement =
  | Seq of statement list
  | SKyojuNim
  | SVarDecl of int * expr
  (**
    예) 슝좍
        슝 (1번 변수)에 좍(=1)을 대입
    - int: 몇 번째 변수인지 (슝=1, 슈웅=2, ...)
    - expr: 대입할 표현식
  *)

  | SOutputAscii of int
  (**
    예) 비비따잇ㅋㅋ
        - '비비따잇'으로 시작
        - 'ㅋㅋ' => 2번 변수의 ASCII 값 출력
    - int: 몇 번째 변수인지
  *)

  | SOutputValue of int
  (**
    예) 비비보호막따잇ㅋㅋ
        - '비비보호막따잇'으로 시작
        - 'ㅋㅋ' => 2번 변수의 '값' 그대로 출력
    - int: 몇 번째 변수인지
  *)

  | SInput of int
  (**
    예) 순수따잇ㅋㅋ
        - '순수따잇'으로 시작
        - 'ㅋㅋ' => 입력 값을 2번 변수에 저장
    - int: 몇 번째 변수인지
  *)

  | SIfZero of statement * expr
  (**
    예) 비비따잇ㅋ 하는재미 슝
        - if문(조건: 슝 변수의 값이 0이면 앞쪽 statement 실행)
        - 앞쪽 statement: SOutputAscii(1)
        - expr: EVar(1) => 슝
    *)

  | SGotoUp of int
  (**
    예) 에잇ㅋ
        - 1줄 위로 이동
    *)

  | SGotoDown of int
  (**
    예) 에잇에잇ㅋㅋㅋㅋ
        - 4줄 아래로 이동
    *)

  | SExpr of expr
  (**
    단순 표현식만 있는 문장 등(필요하다면)
  *)

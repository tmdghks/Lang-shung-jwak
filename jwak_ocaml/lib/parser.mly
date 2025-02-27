%{
open Ast
%}
%token TKyojuNim TEit TEitEit TBiBi TBohoMak THaNeunJaemi TSunSu
%token <int> TSuang       (* 예: "슝", "슈웅", "슈우웅"에서 '우'의 개수 *)
%token <int> TDaIt        (* 예: "따잇", "따따잇", ... 에서 '따'의 개수 *)
%token <int> TKa          (* 예: "ㅋ"의 반복 횟수 *)
%token TPlusOp            (* "~" *)
%token TMinusOp           (* ";" *)
%token TMulOp             (* "," *)
%token TDivOp             (* "@" *)
%token <int> TInteger     (* 예: "좍"은 1, "좌악"은 2, "좌아악"은 3 등 *)
%token TEOF
%token <string> TSyntaxError
%start main
%type <Ast.statement> main

%left TPlusOp TMinusOp  (* 낮은 우선순위 *)
%left TMulOp TDivOp     (* 높은 우선순위 *)
%%

(* 프로그램은 "교주님"으로 시작하며, 여러 문장을 하나의 Seq 노드로 묶습니다. *)
main:
  | TKyojuNim stmts TEOF { Seq(SKyojuNim::$2) }
  ;

(* 문장(statement)들의 리스트 *)
stmts:
  | stmt stmts         { $1 :: $2 }
  | /* empty */        { [] }
  ;

(* 각 문장에 대해 AST 노드를 생성합니다. *)
stmt:
  (* 변수 선언/대입: 예) "슝좍" → 첫 번째 변수(슝 → 내부적으로 n)를 대입 *)
  | TSuang TInteger    { SVarDecl($1, EInt($2)) }
  
  (* 출력(ASCII): 예) "비비따잇ㅋㅋ" → 변수 번호의 ASCII 코드 출력 *)
  | TBiBi TDaIt TKa    { SOutputAscii($2) }
  
  (* 출력(값 그대로): 예) "비비보호막따잇ㅋㅋ" → 변수 번호의 값 그대로 출력 *)
  | TBiBi TBohoMak TDaIt TKa  { SOutputValue($3) }
  
  (* 입력: 예) "순수따잇ㅋㅋ" → 변수 번호에 입력값 저장 *)
  | TSunSu TDaIt TKa   { SInput($2) }
  
  (* if문: 예) "비비따잇ㅋ 하는재미 슝" → 조건(표현식)이 0일 때 앞의 문장을 실행 *)
  | stmt THaNeunJaemi expr  { SIfZero($1, $3) }
  
  (* goto 위: 예) "에잇ㅋ" → 지정한 줄 위로 이동 *)
  | TEit TKa           { SGotoUp($2) }
  
  (* goto 아래: 예) "에잇에잇ㅋㅋㅋㅋ" → 지정한 줄 아래로 이동 *)
  | TEitEit TKa        { SGotoDown($2) }
  
  (* 단순 표현식만 있는 문장 *)
  | expr               { SExpr($1) }
  ;

(* 표현식은 왼쪽 결합 방식으로 이항 연산자를 처리합니다. *)
expr:
  | term               { $1 }
  | expr op term       { EBinOp($1, $2, $3) }
  ;

(* 항: 정수 리터럴 또는 변수 참조 *)
term:
  | TInteger           { EInt($1) }
  | TSuang             { EVar($1) } (* 토큰 자체에서 이미 값을 가지고 있으므로 +1을 제거 *)
  ;

(* 이항 연산자 *)
op:
  | TPlusOp            { OpPlus }
  | TMinusOp           { OpMinus }
  | TMulOp             { OpTimes }
  | TDivOp             { OpDiv }
  ;

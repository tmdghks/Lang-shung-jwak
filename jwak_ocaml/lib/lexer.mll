{
open Parser
}
(* 공백 문자 *)
let whitespace = [' ' '\t' '\n' '\r']+
(* 한글 문자열 기반 토큰 처리.
   실제 구현 시 UTF-8 처리에 유의하세요. *)
rule read_token = parse
  (* 필수 키워드/구분자 *)
  | "교주님"         { TKyojuNim }
  | "에잇에잇"       { TEitEit }
  | "에잇"           { TEit }
  | "비비"           { TBiBi }
  | "보호막"         { TBohoMak }
  | "하는재미"       { THaNeunJaemi }
  | "순수"           { TSunSu }
  
  (* 변수 선언/참조: "슝", "슈웅", "슈우웅", ...  
     "슝"은 TSuang(0)로, "슈우웅"은 '우'의 개수를 이용하여 처리합니다. *)
  | "슝"             { TSuang(1) }
  | "슈" ("우")* "웅" as s
    {
      let len = String.length s in
      let count = (len / 3) in
      TSuang(count)
    }
  
  (* "따잇", "따따잇", ... → TDaIt: '따'의 반복 횟수를 반영 *)
  | ("따")+ "잇" as s
    {
      let len = String.length s in
      let count = (len / 3) in
      TDaIt(count)
    }
      
  (* "ㅋ" 반복 → TKa *)
  | ("ㅋ")* as s     { TKa(String.length s) }
  
  (* 연산자/기호 *)
  | "~"              { TPlusOp }
  | ";"              { TMinusOp }
  | ","              { TMulOp }
  | "@"              { TDivOp }
  
  (* 정수 리터럴: "좍"은 1, "좌" "아"+ "악"은 글자 수에 따라 처리 *)
  | "좍"             { TInteger(1) }
  | "좌" ("아")* "악" as s
    {
      let len = String.length s in
      TInteger(len / 3)
    }
      
  | whitespace       { read_token lexbuf }
  | eof              { TEOF }
  | _ as c           { TSyntaxError (Printf.sprintf "Unexpected character: %s" (String.make 1 c)) }

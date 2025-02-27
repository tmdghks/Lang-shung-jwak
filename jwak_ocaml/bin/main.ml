open Jwak_ocaml.Ast

(* AST를 문자열로 변환하는 함수 *)
let string_of_op = function
  | OpPlus -> "+"
  | OpMinus -> "-"
  | OpTimes -> "*"
  | OpDiv -> "/"

let rec string_of_expr = function
  | EInt n -> string_of_int n
  | EVar n -> "var(" ^ string_of_int n ^ ")"
  | EBinOp(e1, op, e2) -> 
      "(" ^ string_of_expr e1 ^ " " ^ string_of_op op ^ " " ^ string_of_expr e2 ^ ")"

let rec string_of_stmt indent = function
  | Seq stmts -> 
      String.concat "\n" (List.map (fun s -> string_of_stmt (indent + 2) s) stmts)
  | SKyojuNim ->
      "KYOJU_NIM"
  | SVarDecl(var, expr) -> 
      "VAR " ^ string_of_int var ^ " = " ^ string_of_expr expr
  | SOutputAscii(var) -> 
      "OUTPUT_ASCII(var " ^ string_of_int var ^ ")"
  | SOutputValue(var) -> 
      "OUTPUT_VALUE(var " ^ string_of_int var ^ ")"
  | SInput(var) -> 
      "INPUT(var " ^ string_of_int var ^ ")"
  | SIfZero(stmt, expr) -> 
      "IF_ZERO(" ^ string_of_expr expr ^ ") THEN\n" ^ 
      string_of_stmt (indent + 2) stmt ^ "\nENDIF"
  | SGotoUp(n) -> 
      "GOTO_UP(" ^ string_of_int n ^ ")"
  | SGotoDown(n) -> 
      "GOTO_DOWN(" ^ string_of_int n ^ ")"
  | SExpr(expr) -> 
      string_of_expr expr

(* 파일에서 프로그램 파싱 *)
let parse_file filename =
  try
    let channel = open_in filename in
    let lexbuf = Lexing.from_channel channel in
    let ast = Jwak_ocaml.Parser.main Jwak_ocaml.Lexer.read_token lexbuf in
    close_in channel;
    ast
  with
  | Parsing.Parse_error ->
      Printf.eprintf "Parse error in file: %s\n" filename;
      exit 1
  | Sys_error msg ->
      Printf.eprintf "System error: %s\n" msg;
      exit 1

(* 문자열에서 프로그램 파싱 *)
let parse_string str =
  let lexbuf = Lexing.from_string str in
  try
    Jwak_ocaml.Parser.main Jwak_ocaml.Lexer.read_token lexbuf
  with
  | Parsing.Parse_error ->
      Printf.eprintf "Parse error in string: %s\n" str;
      exit 1

(* 메인 함수 *)
let () =
  if Array.length Sys.argv > 1 then
    (* 파일에서 읽어 파싱 *)
    let filename = Sys.argv.(1) in
    let ast = parse_file filename in
    Printf.printf "AST for file %s:\n%s\n" filename (string_of_stmt 0 ast)
  else
    (* 인터랙티브 모드 *)
    let rec loop () =
      Printf.printf "> ";
      flush stdout;
      try
        let line = read_line () in
        if line = "exit" || line = "quit" then exit 0;
        let ast = parse_string line in
        Printf.printf "AST:\n%s\n" (string_of_stmt 0 ast);
        loop ()
      with End_of_file ->
        exit 0
    in
    loop ()

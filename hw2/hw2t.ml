type tests = 
| A | B | C | D | E

let test_gram = (A, [
    A, [N B; N C];
    A, [T "A"];
    B, [N D; N C; T ";"];
    B, [T "test"];
    C, [N C; N B; N C];
    C, [T "C"; N D];
    D, [N A; T ":"; N E];
    D, [N B; T "ok"; N E];
    E, [T "term"]
]);;

let converted_grammar = convert_grammar test_gram;;
let _, converted_rules = converted_grammar
let convert_grammar_test0 = ((converted_rules A) = [[N B; N C]; [T "A"]]);;
let convert_grammar_test1 = ((converted_rules B) = [[N D; N C; T ";"]; [T "test"]]);;
let convert_grammar_test2 = ((converted_rules C) = [[N C; N B; N C]; [T "C"; N D]]);;
let convert_grammar_test3 = ((converted_rules D) = [[N A; T ":"; N D]; [N B; T "ok"; N E]]);;

let test_tree = Node ("+", [
    Node ("*", [
        Leaf 10;
        Node ("-", [Leaf 6])
    ]);
    Node ("/", [
        Leaf 8;
        Leaf 4
    ])
]);;

let parse_tree_leaves_test0 = parse_tree_leaves test_tree = [10; 6; 8; 4];;

let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x
let accept_plus_only = function
    | "+"::_ -> Some ["+"]
    | _ -> None

let make_matcher_test0 = (make_matcher converted_grammar accept_plus_only ["test"; "C"; "A"; ":"; "term"; "+"]) = Some ["+"];;
let make_matcher_test1 = (make_matcher converted_grammar accept_plus_only ["test"; "C"; "A"; ":"; "term"; "-"]) = None;;
let make_matcher_test2 = (make_matcher converted_grammar accept_all ["test"; "C"; "A"; ":"; "term"; "-"]) = Some ["-"];;
let make_matcher_test3 = (make_matcher converted_grammar accept_all ["test"; "C"; "A"; ":"]) = None;;
let make_matcher_test4 = (make_matcher converted_grammar accept_all ["uh"]) = None;;
let make_matcher_test5 = (make_matcher converted_grammar accept_empty_suffix ["A"]) = Some [];;
let make_matcher_test6 = (make_matcher converted_grammar accept_empty_suffix ["A"; "1"]) = None;;

let make_parser_test0 = make_parser converted_grammar ["test"; "C"; "A"; ":"; "term"] = 
    Some
   (Node (A,
     [Node (B, [Leaf "test"]);
      Node (C,
       [Leaf "C";
        Node (D, [Node (A, [Leaf "A"]); Leaf ":"; Node (E, [Leaf "term"])])])]));;
let make_parser_test1 = (make_parser converted_grammar ["test"; "C"; "A"; ":"; "term"; "ok"]) = None

let test_gram2 = (A, [
    A, [N B; N C];
    A, [T "A"];
    B, [N D; N C; T ";"];
    B, [T "C"];
    C, [N C; N B; N C];
    C, [T "C"; N D];
    D, [N A; T ":"; N E];
    D, [N B; T "ok"; N E];
    E, [T "A"]
]);;
let converted_grammar2 = convert_grammar test_gram2;;
let _, converted_rules2 = converted_grammar2
let make_parser_test2 = 
    (make_parser converted_grammar2 ["C"; "C"; "A"; ":"; "A"; "C"; "C"; "A"; ":"; "A"; "C"; "C"; "A"; ":"; "A"]) = 
    Some
    (Node (A,
        [Node (B, [Leaf "C"]);
        Node (C,
        [Node (C,
            [Node (C,
            [Leaf "C";
                Node (D, [Node (A, [Leaf "A"]); Leaf ":"; Node (E, [Leaf "A"])])]);
            Node (B, [Leaf "C"]);
            Node (C,
            [Leaf "C";
                Node (D, [Node (A, [Leaf "A"]); Leaf ":"; Node (E, [Leaf "A"])])])]);
            Node (B, [Leaf "C"]);
            Node (C,
            [Leaf "C";
            Node (D, [Node (A, [Leaf "A"]); Leaf ":"; Node (E, [Leaf "A"])])])])]))
;;

let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x

(* An example grammar for a small subset of Awk.
   This grammar is not the same as Homework 1; it is
   instead the same as the grammar under
   "Theoretical background" above.  *)

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
	 [[N Num];
	  [N Lvalue];
	  [N Incrop; N Lvalue];
	  [N Lvalue; N Incrop];
	  [T"("; N Expr; T")"]]
     | Lvalue ->
	 [[T"$"; N Expr]]
     | Incrop ->
	 [[T"++"];
	  [T"--"]]
     | Binop ->
	 [[T"+"];
	  [T"-"]]
     | Num ->
	 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
	  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let test0 =
  ((make_matcher awkish_grammar accept_all ["ouch"]) = None)

let test1 =
  ((make_matcher awkish_grammar accept_all ["9"])
   = Some [])

let test2 =
  ((make_matcher awkish_grammar accept_all ["9"; "+"; "$"; "1"; "+"])
   = Some ["+"])

let test3 =
  ((make_matcher awkish_grammar accept_empty_suffix ["9"; "+"; "$"; "1"; "+"])
   = None)

(* This one might take a bit longer.... *)
let test4 =
 ((make_matcher awkish_grammar accept_all
     ["("; "$"; "8"; ")"; "-"; "$"; "++"; "$"; "--"; "$"; "9"; "+";
      "("; "$"; "++"; "$"; "2"; "+"; "("; "8"; ")"; "-"; "9"; ")";
      "-"; "("; "$"; "$"; "$"; "$"; "$"; "++"; "$"; "$"; "5"; "++";
      "++"; "--"; ")"; "-"; "++"; "$"; "$"; "("; "$"; "8"; "++"; ")";
      "++"; "+"; "0"])
  = Some [])

let test5 =
  (parse_tree_leaves (Node ("+", [Leaf 3; Node ("*", [Leaf 4; Leaf 5])]))
   = [3; 4; 5])

let small_awk_frag = ["$"; "1"; "++"; "-"; "2"]

let test6 =
  ((make_parser awkish_grammar small_awk_frag)
   = Some (Node (Expr,
		 [Node (Term,
			[Node (Lvalue,
			       [Leaf "$";
				Node (Expr,
				      [Node (Term,
					     [Node (Num,
						    [Leaf "1"])])])]);
			 Node (Incrop, [Leaf "++"])]);
		  Node (Binop,
			[Leaf "-"]);
		  Node (Expr,
			[Node (Term,
			       [Node (Num,
				      [Leaf "2"])])])])))
let test7 =
  match make_parser awkish_grammar small_awk_frag with
    | Some tree -> parse_tree_leaves tree = small_awk_frag
    | _ -> false

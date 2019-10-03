let rec contain num = function
| [] -> false;
| f::l -> if f = num then true
	  else (contain num l)
;;

let rec subset a b = 
match a with
| [] -> true;
| f::l -> if (contain f b) 
	then (subset l b)
	else false
;;

let equal_sets a b = (subset a b) && (subset b a)
;;

let set_union a b = List.append a b
;;

let rec set_intersection a = function
| [] -> []
| f::l -> if (contain f a) 
	then f::(set_intersection l a)
	else (set_intersection l a)
;;

let rec set_diff a b =
match a with
| [] -> []
| f::l -> if (contain f b)
	then (set_diff l b)
	else f::(set_diff l b)
;;

let rec computed_fixed_point eq f x =
	if (eq (f x) x) then x
	else (computed_fixed_point eq f (f x))
;;





type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let filter_reachable g = function
(start, rules) -> (start, rules)
;;





let c = contain 1 []
let c = contain 1 []
let c = contain 1 [1;2;3]
let c = contain 1 [1]
let c = contain 1 [2;3]

let s = subset [] []
let s = subset [] [1; 2; 3]
let s = subset [1; 2; 3; 4] []
let s = subset [1; 2; 3; 4] [1; 2; 3]
let s = subset [1; 2; 3; 4] [1; 2; 3; 4]

let e = equal_sets [] []
let e = equal_sets [1; 2; 3; 4] [1; 2; 3]
let e = equal_sets [1; 2; 3; 4] [1; 2; 3; 4]

let u = set_union [] []
let u = set_union [1; 2; 3; 4] [5; 6; 7; 8]
let u = set_union [1; 2; 3; 4] [4; 5; 6; 7; 8]
let u = set_union [1; 1; 1; 4] [4; 5; 6; 7; 8]

let i = set_intersection [] []
let i = set_intersection [1; 2; 3; 4] [4; 5; 6; 7; 8]
let i = set_intersection [1; 2; 3; 4] [1; 2; 3]

let d = set_diff [] []
let d = set_diff [1; 2; 3; 4] [4; 5; 6; 7; 8]
let d = set_diff [1; 2; 3; 4] [1; 2; 3]
let d = set_diff [1; 2; 3] [1; 2; 3; 4]

type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]]

let awksub_grammar = Expr, awksub_rules

let awksub_test0 =
  filter_reachable awksub_grammar = awksub_grammar

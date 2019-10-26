type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let len list =
	let rec aux n = function
		| [] -> n
		| _::t -> aux (n+1) t
in aux 0 list

(* question 1 *)
let rec converter nterm = function
	| [] -> []
	| (node, rules)::rest ->
		if node = nterm then
			rules::(converter nterm rest)
		else
			(converter nterm rest)

let convert_grammar = function 
	| (start, rules) -> (start, function x -> converter x rules)








(* question 2 *)
let parse f t = function
(* actually parse the nodes *)
	| Leaf leaf -> leaf::(f t)
	| Node (_, rest) -> (f rest) @ (f t) 


let parse_tree_leaves tree = 
let rec loop = function
    | [] -> []
    | h::t -> parse loop t h
in
loop[tree]






(* question 3 *)
let rec looper nodes subfrag func = function
| [] -> None
| h::t -> 
	let ans = func (h @ nodes) subfrag in 
	match ans with 
	| None -> looper nodes subfrag func t
	| any -> any

let make_matcher gram accept frag = 
let start, rules = gram in
let rec aux_matcher nodes subfrag = match nodes with
| [] -> (accept subfrag)
| _ -> 
	if (len nodes) <= (len subfrag) then
		match (List.hd nodes) with 
		| T t -> 
			if (t = (List.hd subfrag)) then
 				aux_matcher (List.tl nodes) (List.tl subfrag)
			else None
		| N nt -> 
			looper (List.tl nodes) subfrag aux_matcher (rules nt)
	else None in
aux_matcher [N start] frag 


(* question 4 *)
let rec looper2 nodes rules frag nt f = function
	| [] -> None
	| h::t ->
		let res = f (h @ nodes) rules frag in
			match res with 
			| None ->
				looper2 nodes rules frag nt f t 
			| Some a -> Some ((nt, h) :: a)

let rec order nodes rules subfrag = match (nodes, subfrag) with
	| ([], []) -> Some []
	| (([], _) | (_, [])) -> None
	| (nodes, subfrag) ->
		if (len nodes) <= (len subfrag) then 
			match (List.hd nodes) with 
			| T t ->
				if (t = (List.hd subfrag)) then
					order (List.tl nodes) rules (List.tl subfrag)
				else None 
			| N nt -> 
				looper2 (List.tl nodes) rules subfrag nt order (rules nt)
		else None 

let rec convert_parse d_tree =
let rec loop_ptree der = function
	| [] -> der, []
	| rh::rt -> 
		match rh with
		| T t ->
			let res = loop_ptree der rt in 
			let (der_left, subtr) = res in
			der_left, ((Leaf t)::subtr)
		| N nt ->
			let last = convert_parse der in
			let (der_left, cur_node) = last in
			let res = loop_ptree der_left rt in
			let (der_left_2, subtr_2) = res in
			der_left_2, (cur_node::subtr_2)

in
let (l,r)::dt = d_tree in
let res = loop_ptree dt r in
let (der_left, subtr) = res in
der_left, Node (l, subtr)

let make_parser gram frag =
let start, rules = gram in
let start_der = function
	| None -> None
	| Some d -> 
		let res = convert_parse d in
		let (_, ptree) = res in
		Some ptree
in
start_der (order [N start] rules frag)

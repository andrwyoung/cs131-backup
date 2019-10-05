type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec contain num = function
| [] -> false;
| h::l -> if h = num then true
	  else (contain num l)

let rec subset a b = 
match a with
| [] -> true;
| h::l -> if (List.mem h b) 
	then (subset l b)
	else false

let equal_sets a b = (subset a b) && (subset b a)

let set_union a b = List.append a b

let rec set_intersection a = function
| [] -> []
| h::l -> if (List.mem h a) 
	then h::(set_intersection l a)
	else (set_intersection l a)

let rec set_diff a b =
match a with
| [] -> []
| h::l -> if (List.mem h b)
	then (set_diff l b)
	else h::(set_diff l b)

let rec computed_fixed_point eq f x =
	if (eq (f x) x) then x
	else (computed_fixed_point eq f (f x))

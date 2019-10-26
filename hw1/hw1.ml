type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

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






(* helper function filtering nonterm rules*)
let rec filter_nonterm = function
[] -> []
| N h::rules -> h::(filter_nonterm rules)
| T h::rules -> filter_nonterm rules

(* main parser: walk through rules adding used ones to list *)
let rec parse_rules cur_nonterms = function 
| [] -> cur_nonterms
| rule::rem_rules ->
	let (lh_rule, rh_rule) = rule in
		if (List.mem lh_rule cur_nonterms)
		then let other_nonterm = filter_nonterm rh_rule in
			parse_rules (set_union cur_nonterms other_nonterm) rem_rules
	else parse_rules cur_nonterms rem_rules

(* keep looping until everything has been used *)
let rec looper good_rules rules = 
let pars1 = parse_rules good_rules rules in
let pars2 = parse_rules pars1 rules in
	if equal_sets pars1 pars2 
		then pars1 
		else looper pars2 rules

let filter_reachable g = 
let (start, rules) = g in
let lh_tup (h,_) = h in
let reach_nonterm_list = (looper [start] rules) in 
let p x = List.mem (lh_tup x) reach_nonterm_list in
(start, List.filter p rules)

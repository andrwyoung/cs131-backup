let c = not (contain 1 [])
let c = contain 1 [1;2;3]
let c = contain 1 [1]
let c = not (contain 1 [2;3])

let s = subset [] []
let s = subset [] [1; 2; 3]
let s = not (subset [1; 2; 3; 4] [])
let s = not (subset [1; 2; 3; 4] [1; 2; 3])
let s = subset [1; 2; 3; 4] [1; 2; 3; 4]

let e = equal_sets [] []
let e = not (equal_sets [1; 2; 3; 4] [1; 2; 3])
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

type l_nonterm =
  | S | A | B | C | E

let rule1 = 
	[S, [N A; N B];
	A, [T "a"];
	B, [T "b"; N C];
	C, [T "c"];
	E, [T "e"]]

(*let f = filter_reachable (S, rule1);*)

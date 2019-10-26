let my_subset_test0 = subset [] []
let my_subset_test1 = subset [] [1; 2; 3]
let my_subset_test2 = not (subset [1; 2; 3; 4] [])
let my_subset_test3 = not (subset [1; 2; 3; 4] [1; 2; 3])
let my_subset_test4 = subset [1; 2; 3; 4] [1; 2; 3; 4]

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = not (equal_sets [1; 2; 3; 4] [1; 2; 3])
let my_equal_sets_test2 = equal_sets [1; 2; 3; 4] [1; 2; 3; 4]

let my_set_union_test0 = set_union [] []
let my_set_union_test1 = set_union [1; 2; 3; 4] [5; 6; 7; 8]
let my_set_union_test3 = set_union [1; 2; 3; 4] [4; 5; 6; 7; 8]
let my_set_union_test4 = set_union [1; 1; 1; 4] [4; 5; 6; 7; 8]

let my_set_intersection_test0 = set_intersection [] []
let my_set_intersection_test1 = set_intersection [1; 2; 3; 4] [4; 5; 6; 7; 8]
let my_set_intersection_test2 = set_intersection [1; 2; 3; 4] [1; 2; 3]

let my_set_diff_test0 = set_diff [] []
let my_set_diff_test1 = set_diff [1; 2; 3; 4] [4; 5; 6; 7; 8]
let my_set_diff_test2 = set_diff [1; 2; 3; 4] [1; 2; 3]
let my_set_diff_test3 = set_diff [1; 2; 3] [1; 2; 3; 4]

type l_nonterm =
  | S | A | B | C | E

let rule1 = 
	[S, [N A; N B];
	A, [T "a"];
	B, [T "b"; N C];
	C, [T "c"];
	E, [T "e"]]

let my_filter_reachable_test0 = filter_reachable (S, rule1)

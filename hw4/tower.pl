tower(N, T, C) :-
	% make the array
	length(T, N), 		%ensure T is [[], [], [], []]
	buildT(N, T), 		% vertically correct
	transpose(T, TT),
	buildT(N, TT), 		% horizontally correct

	% figure out the borders
	C = counts(Up, Down, Left, Right),
  	maplist(reverse, T, T_Rev),
	maplist(checkRow, T, Left),
  	maplist(checkRow, T_Rev, Right),
	maplist(reverse, TT, T_TRev),
	maplist(checkRow, TT, Up),
	maplist(checkRow, T_TRev, Down).

plain_tower(N, T, C) :-
	% make the array
	length(T, N), 		%ensure T is [[], [], [], []]
	build_plainT(N, Opts),

	maplist(permutation(Opts), T),
	transpose(T, TT),
	maplist(permutation(Opts), TT),

	% figure out the borders
	C = counts(Up, Down, Left, Right),
  	maplist(reverse, T, T_Rev),
	maplist(checkRow, T, Left),
  	maplist(checkRow, T_Rev, Right),
	maplist(reverse, TT, T_TRev),
	maplist(checkRow, TT, Up),
	maplist(checkRow, T_TRev, Down).

	

buildT(N, []).
buildT(N, [H | T]) :-
	length(H, N), 			% ensure each sub list is [_,_,_,_]
	fd_all_different(H), 	% with all different thing...
	fd_domain(H, 1, N), 	% ...from 1 to N...
	fd_labeling(H),			% ...labeled with numbers
	buildT(N, T).

build_plainT(0, []).
build_plainT(N, [N | T]) :-
	N > 0, NextN is N-1,
	build_plainT(NextN, T).

checkRowForward([], L, _, L).
checkRowForward([H | T], L, CurMax, FinalL) :-
	H > CurMax, 
		NewL is L+1, checkRowForward(T, NewL, H, FinalL)
	; H < CurMax,
		checkRowForward(T, L, CurMax, FinalL). 

checkRow(Row, L) :- 
	checkRowForward(Row, 0, 0, L).




%transposing a matrix found online
transpose_column([], L, L) :-
  once(maplist(=([]), L)).
transpose_column([E|Es], [[E|R1]|L], [R1|R]) :-
  transpose_column(Es, L, R).
transpose([], L) :-
  once(maplist(=([]), L)).
transpose([C|Cs], L) :-
  transpose_column(C, L, R),
  transpose(Cs, R).











% (part 2) stats:
test_tower(Time) :-
  statistics(runtime, [Start | _]),
  tower(4, T, counts([4,2,2,1],[1,2,2,4],[4,2,2,1],[1,2,2,4])),
  statistics(runtime, [Stop | _]),
  Time is Stop - Start.

test_plain_tower(Time) :-
  statistics(runtime, [Start | _]),
  plain_tower(4, T, counts([4,2,2,1],[1,2,2,4],[4,2,2,1],[1,2,2,4])),
  statistics(runtime, [Stop | _]),
  Time is Stop - Start.

speedup(Ratio) :-
  test_tower(Time1),
  test_plain_tower(Time2),
  Ratio is Time2/Time1.




% (part 3) ambiguous:
ambiguous(N, C, T1, T2) :-
	tower(N, T1, C),
	tower(N, T2, C),
	T1 \= T2.

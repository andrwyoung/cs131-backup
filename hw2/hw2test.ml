let accept_all string = Some string

type awksub_nonterminals =
  | Sentence | Subject | Adverb | Verb | Adj | Object

let grammar =
(Sentence,
function
	| Sentence ->
		[[N Subject; N Verb; N Object];
		[N Subject; N Verb; N Adj; N Object];
		[N Subject; N Adverb; N Verb; N Object];
		[N Subject; N Adverb; N Verb; N Adj; N Object];
		[N Verb]]
	| Subject ->
		[[T"The man"];
		[T"The woman"]]
	| Adverb ->
		[[T"frantically"];
		[T"happily"]]
	| Verb ->
		[[T"hits the"];
		[T"runs towards the"]]
	| Adj ->
		[[T"yellow"];
		[T"black"]]
	| Object ->
		[[T"dog"];
		[T"child"]])

let frag = ["The man"; "happily"; "hits the"; "dog"]


(* the tests *)
let make_matcher_test =
  (make_matcher grammar accept_all ["The woman"; "runs towards the"; "yellow"; "child"]
  = Some [])

let make_parser_test =
  (make_parser grammar frag)
  = Some
   (Node (Sentence,
     [Node (Subject, [Leaf "The man"]); Node (Adverb, [Leaf "happily"]);
      Node (Verb, [Leaf "hits the"]); Node (Object, [Leaf "dog"])]))

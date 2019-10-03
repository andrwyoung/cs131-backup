default: test.ml
	ocamlbuild test.native && ./test.native

#lang racket
(define LAMBDA (string->symbol "\u03BB"))

#| HELPERS |# 
(define (if_mismatch? x y)
  ; (print "if mismatch")
  (xor (equal? x 'if) (equal? y 'if))
)

(define (same_func? x y)
  (or
    (if_mismatch? x y)
    (xor (equal? x 'quote) (equal? y 'quote))
    (xor (equal? (lambda? x) 'if) (equal? (lambda? y) 'if))
  )
)

(define (extend l . xs)
  (if (null? l) 
      xs
      (cons (car l) (apply extend (cdr l) xs))))


#| LAMBDA HELPER FUNCTIONS |#
; does x!y
(define (exclam x y)
  (string->symbol (string-append (symbol->string x) (string-append "!" (symbol->string y))))
)

(define (lambda? x)
  (or (equal? x 'lambda) (equal? x LAMBDA))
)

(define (unicode_lambda x y)
  (if (or (equal? x LAMBDA) (equal? y LAMBDA))
      (list LAMBDA)
      (list 'lambda)
  )
)


(define (lambda-symbol x y)
  (if
    (not (equal? x y))
    (list LAMBDA)
    (list x)
  )
)




#| LAMBDA MAIN FUNCTIONS |#
; if "first," then it can have ! in it
(define (check_lambda_list x y first)
  (if (and (list? x) (list? y))
      (cond
          [(and (equal? x empty) (equal? y empty))
            '()
          ]
          [(equal? (car x) (car y))
            (cons (car x) (compare-lambda (cdr x) (cdr y) #f))
          ]
          [else
            (if (equal? first #t)
                (cons (list 'if '% (car x) (car y)) (compare-lambda (cdr x) (cdr y) #f))
                (cons (exclam (car x) (car y)) (compare-lambda (cdr x) (cdr y) #f))
            )
          ]
        )
     (list 'if '% x y)
  )
)

; append lambda-symbol
(define (check_lambda x y)
  ; if x (and therefore y) is more than 2 items
  (if (list? (caddr x))
     (append (unicode_lambda (list-ref x 0) (list-ref y 0))
        (append (list (check_lambda_list (cadr x) (cadr y) #t))
                (list (check_lambda_list (caddr x) (caddr y) #t))))


     (append (unicode_lambda (list-ref x 0) (list-ref y 0))
        (append (list (check_lambda_list (cadr x) (cadr y) #t))
                      (check_lambda_list (caddr x) (caddr y) #t)))
  )
)







#| MAIN FUNCTIONS |#
; used to check constants and base cases
(define (check_const x y)
  ; (print "bcase")
  (cond
    [(equal? x y) x]
    [(and (boolean? x) (boolean? y))
     (if x '% '(not %))
    ]
    ; if there is a difference
    [else (list 'if '% x y)]
  )
)

; level 3 sorting: individual items
(define (check_item x y)
  (print "check_item")
  (cond
    ; check if functions are the same:
    [(same_func? x y) (list 'if '% x y)]
    [(and (equal? (car x) 'quote) (equal? (car y) 'quote))
      (check_const x y)
    ]
    [(and (lambda? (car x)) (lambda? (car y)))
      (check_lambda x y)
    ]
    [else
      (cons (expr-compare (car x) (car y)) (expr-compare (cdr x) (cdr y)))
    ]
  )
)

; level 2 sorting: lists (mainly length)
(define (check_lists x y)
  ; (print "check_lists")
  (cond
    [(equal? x y) x]
    ; lengths are same -> check each item
    [(equal? (length x) (length y))
      (print "lists are equal")
      (if (and (equal? (length x) 4) (if_mismatch? (car x) (car y)))
        (list 'if '% x y)
        (check_item x y)
      )
    ]
    ; if lengths are different
    [else (list 'if '% x y)]
  )
)

; level 1 sorting: is it a list?
(define (expr-compare x y)
  ; (print "start")
  (if
    (and (list? x) (list? y))
    (check_lists x y)
    (check_const x y)
  )
)








#| TESTING FUNCTIONS |#
(define (test-expr-compare x y)
  (and
    (equal? (eval x) (eval (list 'let '((% #t)) (expr-compare x y))))
    (equal? (eval y) (eval (list 'let '((% #t)) (expr-compare x y))))
  )
)

(define test-expr-x
	(list
		; all combinations for true and false
		#t
		#t
		#f
		#f
		; number literals
		12
		12
	)

)

(define test-expr-y
	(list
		#t
		#f
		#t
		#f
		12
		20
	)
)


;
; factorial.scm - compute the factorial function, recursively.
;
; This implements a classic textbook algorithm for computing the
; factorial. It defines the factorial function as `f(n) = n * f(n-1)`
; and using an if statement (conditional) to terminate recursion when
; `n` reaches 1.  This is tail-recursive: no stack in either C++ or
; in scheme (or in "Atomese") will increase in size.
;
; This is an imperfect demo: although it does show that classic
; recursive algorithms can be implemented in Atomese, this is not
; really recommended programming practice, for the following reasons:
;
;  * The AtomSpace is a database. Whatever atoms get created as a result
;    of the algorithm will continue to live in the AtomSpace,
;    indefinitely. Is this something you really want? Badly-written
;    algos risk filling the AtomSpace with junk nodes - be careful!
;
;  * Running algorithms in Atomese is slow. It's not intended to be
;    a high-performance numerical computing platform; it is meant to
;    be a general-purpose knowledge-representation and reasoning system.
;
;  * A better example of numerical computation in the AtomSpace is the
;    processing of Values. Values are inherently fleeting, and are much
;    more numerically-oriented. Other examples show how. 
;
(use-modules (opencog) (opencog exec))

; Compute the factorial of a NumberNode, using the classic
; recursive algorithm.
;
(Define
	(DefinedSchema "factorial")
	(Lambda
		; A single argument; it must be a number
		(TypedVariable (Variable "$n") (Type "NumberNode"))

		; Conditional: if the first term (the conditional) 
		; evaluates to "true", then the second term (the
		; consequent) will be executed; else the third term
		; (the alternative) will be executed
		(Cond
			; The condition: `n>0`
			(GreaterThan (Variable "$n") (Number 0))

			; The consequent: `f(n) = n * f(n-1)`
			(Times
				(Variable "$n")
				(ExecutionOutput
					(DefinedSchema "factorial")
					(Minus (Variable "$n") (Number 1))))

			; The alternative: `f(1) = 1`
			(Number 1)))
)

; Call the above-defined factorial function, computing the
; factorial of five. Should return 120.
; (cog-execute! (ExecutionOutput (DefinedSchema "factorial") (Number 5)))

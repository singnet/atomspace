
Arithmetic and term reduction for atoms
---------------------------------------

This is an implementation of arithmetic and arithmetic (algebraic)
reduction for the AtomSpace. It works, but suffers from various design
flaws.  It is a proof-of-concept, and should be redesigned.

First, a few words about what it does; then a few words about its flaws.

### What it does
This allows arithmetic expressions to be declared in the AtomSpace.
Arithmetic is any finite algebraic expression consisting of addition,
subtraction, multiplication and division. It excludes infinite series,
inferior and superior limits, integrals. These require second-order
logic, whereas arithmetic is compatible with first-order logic.

By allowing arithmetic expressions to be declared in the AtomSpace,
various kinds of learning and reasoning algorithms can manipulate them.
For example, MOSES, Pattern Mining, or some neural net system can
discover brand-new arithmetic expressions, and stick them in the
AtomSpace.

At the same time, the code in this directory allows arithmetic
expressions to be evaluated, to get numeric results. In particular,
these arithmetic expressions can be applied to FloatValues, TruthValues
and AttentionValues. That is, it can be executed on the fly to create
new TruthValues, and so on.

This is particularly interesting for systems like PLN. The code here
allows PLN formulas to be stored in the AtomSpace, while also being
run evaluatable, so as to generate the actual TV's that PLN needs to
calculate. Keeping the formulas here provides a significant performance
enhancement over computing formulas in scheme or python: both of those
systems need about 50 microseconds to get in and out of them, limiting
you to about 20K formulas/second.  The code here is much faster.

### What's wrong with it
Although multiplying numbers here is 100x faster than calling the guile
or cython interpreters, it is also 100x slower than native CPU insns.
In some future implementation, the formulas would be compiled down to
bytecode of some kind. Maybe the JVM, but maybe also GNU Lightening.

The code here also implements term reduction. It is very ad-hoc. It
works, it's awkward, its hard to write, its not easy to extend. The
correct solution for term reduction would be to create an actual algebra
system: that is, to write a bunch of rule engine rules that perform
algebraic reduction. This would be more maintainable than reduct in C++.

By "term reduction", I mean reducing expressions like x+x to 2x, or
reducing x+0 to just x. More complex examples, too: 6(x/2) == 3x and
so on.

## Examples
I believe the following examples all work. See also the AtomSpace
[examples](../../../examples/atomspace) directory for more examples.
Take a good look at `stream.scm` in particular.

Anyway... try this at the guile prompt:
```
(cog-execute! (PlusLink (NumberNode 2) (NumberNode 2)))
```

you should see `(NumberNode 4)` as the output.

A more challenging example:
```
(cog-execute! (PlusLink (NumberNode 0) (VariableNode "$x")))
```

should yield `(VariableNode "$x")` -- that is, adding zero to something
has no effect!

Some more interesting examples:
```
(cog-execute! (PlusLink (NumberNode 2) (VariableNode "$x") (NumberNode -2)))
```

should yield `(VariableNode "$x")` -- the +2 and -2 cancel.

```
(cog-execute! (PlusLink (NumberNode 2) (VariableNode "$x") (NumberNode 2)))
```

should yield `(PlusLink (VariableNode "$x") (NumberNode 4))` --
the +2 and +2 sum.

Using the same ideas:
```
(cog-execute! (TimesLink (NumberNode 1) (VariableNode "$x")))

(cog-execute!
   (TimesLink
      (VariableNode "$y")
      (NumberNode 1)
      (VariableNode "$x")))

(cog-execute!
   (TimesLink
      (VariableNode "$y")
         (NumberNode 0.5)
         (VariableNode "$x")
         (PlusLink (NumberNode 1) (NumberNode 1))))
```

Not sure, but reduction of x+2x to 3x and x+(-x) to 0 should work.

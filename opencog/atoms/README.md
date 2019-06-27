
Atoms
=====

This directory contains C++ implementations of many (but not all)
atom types as C++ classes (some atom types do not need an underlying
C++ class to make them work).

The goal of having a C++ class is two-fold. One is to implement methods
that "do something" for that atom type. For example, the `PlusLink` can
actually add numbers together, in addition to holding the symbolic
expressions to be added.  Another goal of having C++ classes is that
they allow caching, pre-processing and memoization. For example, the
pattern matcher needs to know where all the variables are in a pattern;
the `PatternLink` pre-analyzes the pattern and memoizes the variable
locations. The `PatternLink` holds the "compiled" version of the
pattern.

See the [README](../README.md) one level down for a quick definition
of what an Atom is.

See the [AtomSpace README](../atomspace/README.md) for a discussion of
design tradeoffs, and of the current implementation.

Subdirectories
--------------
Listed in order of dependency:

 * `atom_types` -- The `atom_types.script` file in this directory
   declares the `Value` and `Atom` type hierarchy. Includes the
   `nameserver`, which provides misc run-time services, describing
   the type hierarchy and the names of types.

 * `value` -- The C++ base class for Atoms and for Values. The
   `FloatValue`, `StringValue` and `LinkValue` are defined here.

 * `truthvalue` -- various kinds of `TruthValue`s are defined here.

 * `base` -- The C++ base classes for `Atom`, `Node` and `Link` are
   defined here. The Atom factory (aka `classserver`) is defined here.

 * `core` -- A large collection of Atoms that have "fairly simple"
   C++ classes behind them.  Here, "fairly simple" means that they do
   not depend on other C++ subsystems, such as scheme, python, the
   pattern matcher, etc.

 * `pattern` -- Atoms involved with pattern matching: `BindLink`,
   `GetLink`, `DualLink`, `SatisfactionLink`, `SatisfactionSetLink`.
   These are al quite complicated, and cache various pre-compiled
   parts of the pattern.

 * `execution` -- "black-box" executable/evaluatable links, e.g.
   `ExecutionOutputLink`, `EvaluationLink`, `GroundedPredicateNode`,
   etc.  These interact with the scheme, python and haskell evaluators.

 * `reduct` -- inspired by comboreduct, these are "clearbox" links:
   `PlusLink`, `TimesLink`, etc. They not only represent arithmetic
   formulas, but can also add and multiply numbers.  They are
   "clearbox" because they not only "do something" (like the black-box
   Atoms), but we also know what they do.  For example, `PlusLink` adds
   numbers.  By contrast, it is impossible to know what some black-box
   might do. Thus, we can apply reasoning and deduction to the clearbox
   links, which is impossible for the black-box links.

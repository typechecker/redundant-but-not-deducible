# redundant-but-not-deducible

I struck a problem where GHC says that a constraint is redundant but GHC then
says the constraint is not deducible if I remove it. This is a reproduction of
the problem.

The `module Client` compiles with `ghc-8.10.7 .. ghc-9.2.2` fine but from
`ghc-9.2.3` we see the problem.

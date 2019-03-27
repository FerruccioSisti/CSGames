# The Purest Language

  A sacred book describing the purest language, Lambda Calculus, has
been found on a deserted island. Unfortunately, some parts have been
left as an exercice to the reader (a common occurence in FP
scripture). You have to complete these exercises to demonstrate your
mastery of FP.

## Lambda Calculus

  [Lambda calculus] is a formal system, that, while being Turing
complete, remains very simple. Indeed, the abstract language is
composed of only three kinds of expressions. Here is the definition of
the corresponding data type taken from the file `Language.hs`:

```haskell
type Symbol = String
data Expr = Var Symbol
          | Lambda Symbol Expr
          | App Expr Expr
```

  We can see that a lambda expression is either a variable, a lambda
abstraction, or an application. A lambda abstraction is essentially an
anonymous function definition, that binds a symbol to an argument that
can then be used inside its sub-expression. The application is built
with two sub-expressions: the function and the argument. During
evaluation, the function is evaluated to a lambda, and the lambda's
symbol can then be substituted by the argument in the lambda's
body. As an example, the term `Lambda "x" (Var "x")` is a lambda
expressing the identity function. `Lambda "a" (Lambda "b" (App (Var
"a") (Var "b")))` is a function that takes two arguments and applies
the first to the second (every lambda takes only one argument, but
conceptually, this lambda can be applied twice).

  The usefulness of lambda calculus comes from the fact that it is a
good abstraction for programs (simple, composable, and Turing
complete). It is widely used in the field of programming language
theory because of its [correspondence to proofs] that allows for the
development of nice type systems and safer programs.

[Lambda calculus]: https://en.wikipedia.org/wiki/Lambda_calculus
[correspondence to proofs]: https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence

## Lambdastic

  For these exercises, you will work with a small lambda calculus
language, enthusiastically named `Lambdastic`. A parser,
pretty-printer, and REPL have already been written.

### Concrete Syntax

  - Variables start with a letter and can contain letters, digits,
    underscores and single quotes.
  - The syntax for abstraction is `\ x -> expr`.
  - The syntax for application is `$ fun arg`.
  - The syntax for assignements is `identifier = expr.`. They are
    implemented like macros system: the identifier is only bound after
    the assignement. It is thus not correct to write `x = x` for
    instance.  This does not allow recursion directly, but it is
    possible to define a recursive function with the help of the `fix`
    function, as we will see.
  - Additionally, there is a syntax for modules and imports for our
    macro system. This allows us to use assignements from other files.
  - Module, import and assignment statements are separated by `.` (a
    single dot).
  - We have synctactic sugar to abstract/apply over multiple arguments
    at a time: `\ a b c -> expr` is equivalent to `\ a -> \ b -> \ c
    -> expr`. `$ a b c` is equivalent to `$ ($ a b) c`.
    *Unfortunately, this makes it hard to see which arguments belong
    to which application; use parentheses!*
  - Syntactic sugar for let expressions: `let x=exprx, y=expry in
    exprz` is equivalent to `$ (\ x -> ($ (\ y -> exprz) expry))
    exprx`.
  - `--` starts a line comment, `{-` and `-}` enclose multi-line
    comments, like in Haskell.

  Look at the `*.lam` files for examples.

### Project structure

  The project has the following structure:

1. The `lib` directory contains the core implementation of the language:
  - `Language.hs` contains the core language data types.
  - `Evaluation.hs` has stubs for different evaluation functions that
    you will implement.

2. `src` contains the sources for the REPL executable.

3. `test` contains various tests.

4. The `*.lam` files are examples and of lambdastic source code.
  - `base.lam` defines a set of functions that you can use in the rest
    of your code. It mostly defines the Church encoding of datatypes
    such as booleans, natural numbers and lists.
  - `eval.lam` and `lib.lam` contain stubs for functions that you will
    have to implement.

## How to

The tests for the Haskell code can be run with the following command:

```
$ cabal new-test
```

You can also focus the tests with a pattern:

```
$ cabal new-run test -- --pattern <pattern>
```

To start the interpreter, run this:

```
$ cabal new-run lambdastic
$ # you can also import ".lam" files from the start :
$ cabal new-run lambdastic -- base.lam lib.lam
```

Here is a small demonstration of the features of the REPL:

```haskell
$ cabal new-run lambdastic
Up to date
Welcome to the Lambdastic interpreter!
> -- The interpreter has TAB completion for commands and bound identifiers.
> -- Here we have not loaded or defined anything yet.
> <TAB><TAB>
:load    :import  :set     :info    :equal   :int
> :import base.lam -- :import and :load are synonyms
Loaded base.
> <TAB><TAB>
add           five          omega         ten           :set
...
> -- We can see that some functions have been loaded.
> a = let yes=true, no=false in $ if true yes no -- a useless definition
a =
  $ (\ yes ->
      $ (\ no -> $ (\ b t e -> $ b t e) (\ a b -> a) yes no)
        (\ a b -> b))
    (\ a b -> a)
> -- Notice that the evaluation function has not yet been implemented,
> -- the lambda term is simply echoed back initially (see exercice 1).
> x = x -- incorrect
Unbound symbols : ["x"]
> :int five -- Evaluate and print a number
Just 5
> :equal ten, ten -- Compare terms (infinite loop for some terms)
True
> <Ctrl-D>
Goodbye.
```

# Exercises

## 1. Complete the evaluation functions [10 points]

For this exercice, you will implement two evaluation strategies for
our language: *call by value* and *call by name*. Lambda expression
are reduced through beta-reduction: if a lambda abstraction is
applied, beta-reduction substitutes all the occurences of the
abstraction's bound symbol inside the sub-expression by the argument.
For example, the term `$ (\ x -> $ x x) y` is beta-reduced to `$ y
y`. If there are multiple redexes (reducibles expressions) inside an
expression, an evaluation strategy dictates the order in which the
reductions happen.

See the wiki
[article](https://en.wikipedia.org/wiki/Lambda_calculus#Beta_reduction)
for more details. Note that we can avoid the need for alpha-renaming
by using a substitution function that is aware of scoping rules
(`substitute` in `lib/Language.hs`).

In `lib/Evaluation.hs`, complete the functions `evalStepsCallByName`
and `evalStepsCallByValue`. Both functions take a lambda expression
and give the list of expressions corresponding to every reduction
step, in order. Thus, the last expression in the list is not reducible
with that evaluation strategy (it is "stuck"). The first element of
the returned list is always the expression given as an argument. This
way, the list is never empty.

For both strategies (but not in the already implemented normal order
evaluation), lambda abstractions are always stuck. In other words,
these evaluation strategies will not "look into" the body of
abstractions, even if the contain redexes.

The `CallByName` strategy beta-reduces the left-most outermost
application for which the function is a lambda abstraction. In other
words, for a given application, it will first reduce the function,
then do the beta-reduction, even if the arguments are not reduced.

The `CallByValue` strategy starts by reducing the function, then the
argument, then it does the beta-reduction. This strategy is "strict",
meaning that the arguments to a function are evaluated even if they
are not used in the body of the function.

Examples of reduction steps for both strategies can be found in
`test/TestEval.hs`.

## 2. A very special term [10 points]

For some lambda expressions and some strategies, the evaluation does
not terminate. For example, the term `omega` in `base.lam` "diverges"
under all the strategies in `Evaluation.hs`.

Using `omega`, find a term for which evaluation terminates under
either one of call-by-name or call-by-value, but not the other of
those two. Assign this lambda expression to `diverges_in_one_order` in
the file `eval.lam`.

## 3. Write your own Lambdastic functions! [20 points]

Complete the functions in `lib.lam`. Use the definitions from
`base.lam` and consult the wiki page on [Church
encoding](https://en.wikipedia.org/wiki/Church_encoding) if needed.

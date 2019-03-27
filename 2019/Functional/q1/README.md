# Q1 : Warm-up

Here are a few introductory exercises to test your ability to
structure recursion and use higher-order functions.

## Setup

The sources on which you will be working are in the `src`
directory. Additionally, there are tests defined in the `test`
directory. You can run all the tests (including those for given
functions) with the following command:

```
$ cabal new-test
```

It will probably be more productive to focus on a single set of tests
at a time. For example, if you are working on the function
`tailRecFibonacci`, run the command:

```
$ cabal new-run test -- --pattern tailRecFib
```

## 1.1 : Tail Recursion

FP languages without local mutable variables (e.g. Haskell, Erlang and
Clojure) often do not have an explicit looping control
structure. Instead, programmers have to write tail-recursive
functions, which are optimized by the compiler to use a constant
amount of memory (stack frames are recycled).

The file `Recursion.hs` contains 3 recursive functions (they are
prefixed with `rec`). Re-implement them in a tail-recursive fashion,
using the `tailRec`-prefixed function stubs given in the same
file. Use helper functions if a different list of arguments is needed
for the tail-recursion.

*Note : Do not use higher-order functions like `map` or `foldl` in
this exercice.*

### 1.1.1 : Fibonacci *[1 point]*

`recFibonacci` returns the `n`th Fibonacci number where `n` is an
integer given as an argument.

### 1.1.2 : FizzBuzz *[1 point]*

`recFizzBuzz` returns a list of strings that represent integers from 1
to it's argument `n` (inclusively), where multiples of 3 are replaced
by the string "Fizz", multiples of 5 by the string "Buzz" and
multiples of both by the string "FizzBuzz".

### 1.1.3 : Fast exponentiation ([exponentiation by squaring]) *[3 points]*

`recExp` implements a generic form of exponentiation by squaring. It
relies on the observation that `base^exponent =
(base^step)^floor(exponent/step) * base^(exponent **modulo**
step)`. We generally use `step = 2` (squaring), but any small value
could work. This algorithm allows us to perform exponentiation in a
logarithmic number of multiplication operations.

The function `simpleExp` is used as a helper function for small
exponents.

[exponentiation by squaring]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring

## 1.2 : Higher-Order Functions

Often, using a recursive function on its own just to make a loop can
be excessively verbose. Thankfully we can often replace our recursion
with a higher-order function. 

Rewrite the functions given in `HigherOrderFunctions.hs` in such a way
that their behavior remains the same, but without recursion, instead
using higher-order functions such as `foldl`, `map`, `scanl`, `zip`,
`maximumBy`, etc.

### 1.2.1 : Fitting squares *[2 point]*

`recFitSquares` takes an upper bound `m` and returns the maximum value
`n` such that the sum of the squares of natural numbers smaller than
`n` is smaller than `m`.

![`n = max \left \{ e \in \mathbb{N} \mid \sum_{i=1}^{e-1} i^2 < m \right \}`](Eqn_1_2_1.gif)

Use the stub `hoFitSquares` for your version.

### 1.2.2 : Representative Word *[3 points]*

`recRepresentativeWord` takes a list of words and return the word with
the most occurences of the most frequent letter. The most frequent
letter is chosen in a case-insensitive way, and in case of equal
number of occurences, we choose the first in alphabetic order. If
multiple words have the maximum number of occurences, then we choose
the first in lexicographic order (where uppercase letters come before
lowercase letters).

The version given as a reference is unreadable, but its behavior is
right. Follow the description above as a guide.

Use the stub `hoRepresentativeWord` for your version.

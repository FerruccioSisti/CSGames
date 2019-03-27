# Purity Through Persistence [10 points]

  In order to avoid the great dangers of parallelism, Functional
Programming practitioners often choose to disallow mutation (or at
least avoid it in contexts where aliasing is possible). This
constraint forces them to use special data structures that work
without mutation.

  Persistent data structures preserve their previous versions when
they are modified. Since these different versions often share
structure, their operations still have acceptable complexity bounds,
even with the added immutability property.

  The simplest example of a persistent data structure is the singly
linked list: consing a new element at the head preserves the old list
and the resulting list shares its tail with the old one.

  Implement a persistent queue using two stacks (singly linked lists),
as described in the slides 13-20 from [this
course](https://www-users.cs.umn.edu/~kauffman/2041/12-persistent-data-structs.pdf).

  Use the function stubs in `src/Queue.hs`. Some tests have already
been written in `test/TestQueue.hs`. You can run them with the
following command:

```
$ cabal new-test
```

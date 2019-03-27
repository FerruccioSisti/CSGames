# La pureté par la persistence [10 points]

  Dans le but d'éviter les grands dangers du parallélisme, les adeptes
de programmation fonctionnelle choisissent souvent d'interdire la
mutation, ou du moins l'éviter dans les contextes où le partage de
références est possible. Cette contrainte les force à utiliser des
variantes particulières de structures de données qui fonctionnent sans
mutation.

  Les structures de données persistantes préservent leurs anciennes
versions quand elles sont modifiées. Puisque ces différentes versions
partagent souvent une partie de leur structure, leurs opérations
conservent des complexités acceptables. Et cela, en plus d'avoir la
propriété intéressante d'être immutable.

  L'exemple le plus simple de structures de données persistantes est
celui de la liste chaînée simplement: l'insertion d'un élément en tête
conserve et partage la mémoire avec l'ancienne version de la liste.

  Implantez une file persistante à l'aide de deux piles (listes
simplement chaînées), de la façon décrites dans les diapositives 13 à
20 de [ce
cours](https://www-users.cs.umn.edu/~kauffman/2041/12-persistent-data-structs.pdf).

  Utilisez les *stubs* de fonction dans le module
`src/Queue.hs`. Quelques tests se trouvent déjà dans
`test/TestQueue.hs`. Pour les exécuter, lancez:

```
$ cabal new-test
```

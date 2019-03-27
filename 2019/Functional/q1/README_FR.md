# Q1 : Échauffement

Voici quelques exercices d'introduction pour vérifier votre habilité à
utiliser la récursion et les fonction d'ordre supérieur.

## Projet donné

Le code sur lequel vous allez travailler se trouve dans le répertoire
`src`. De plus, des tests sont définis dans le répertoire `test`. Pour exécuter ces tests, lancez la commande suivante:

```
$ cabal new-test
```

Il sera probablement plus productif de se concentrer sur un ensemble
de tests restreint. Si vous travaillez sur la fonction
`tailRecFibonacci`, lancez plutôt:

```
$ cabal new-run test -- --pattern tailRecFib
```

## 1.1 : Récursion terminale (Tail Recursion)

Les langages de programmation fonctionnelle sans variable locales
mutables (p.ex. Haskell, Erlang et Clojure) n'ont souvent pas de
structure de contrôle explicite pour les boucles. À la place, un
programmeur utilisera la récursion terminale, qui sera optimisée par
le compilateur pour effectuer une boucle avec une quantité de mémoire
constante.

Le fichier `Recursion.hs` contient 3 fonctions récursives (préfixées
par `rec`). Ré-implantez ces fonctions en faisant des appels terminaux
pour les boucles. Utilisez les fonctions *stubs* commençant par
`tailRec`, dans le même fichier. Utilisez des fonctions auxiliaires au
besoin.

*Note: N'utilisez pas de fonction d'ordre supérieur pour cette partie.*

### 1.1.1 : Fibonacci *[1 point]*

`recFibonacci` retourne le `n`ième nombre de Fibonnaci, où `n` est un entier donné en paramètre.

### 1.1.2 : FizzBuzz *[1 point]*

`recFizzBuzz` retourne une liste de chaînes de caractères qui
représentent les entier de 1 jusqu'au paramètre `n`
(inclusivement). Les multiples de 3 sont remplacés par la chaîne
"Fizz", les multiples de 5 par la chaîne "Buzz" et les multiples des
deux par la chaîne "FizzBuzz".

### 1.1.3 : [Exponentiation rapide] *[3 points]*

`recExp` implante une version générique de l'algorithme d'exponention
rapide. Celui-ci se base sur l'identité suivante.

`base^exponent = (base^step)^floor(exponent/step) * base^(exponent
**modulo** step)`

On utilise généralement `step = 2` (mettre au carré), mais n'importe
quelle petite valeur pourrait fonctionner. Cela permet d'effectuer
l'exponentiation en un nombre logarithmique de multiplications.

La fonction `simpleExp` est utilisée comme fonction auxiliaire pour
les petits exposants.

[Exponentiation rapide]: https://fr.wikipedia.org/wiki/Exponentiation_rapide

## 1.2 : Fonctions d'ordre supérieur

Souvent, écrire une fonction récursive pour faire une simple boucle
peut être excessivement verbeux. Heureusement, on peut souvent
remplacer cette récursion par un appel à des fonctions d'ordre
supérieur.

Dans cet exercice, réécrivez les fonctions se trouvant dans
`HigherOrderFunctions.hs` de façon à ce que leur comportement reste
identique, mais sans récursion explicite, en utilisant plutôt des
fonctions d'ordre supérieur comme `foldl`, `map`, `scanl`, `zip`,
`maximumBy`, etc.

### 1.2.1 : Remplissage de carrés *[2 point]*

`recFitSquares` prend en paramètre une borne supérieure `m` et
retourne la valeur maximale `n` telle que la somme des carrés des
nombres naturels strictement inférieurs à `n` soit strictement
inférieure à `m`.

![`n = max \left \{ e \in \mathbb{N} \mid \sum_{i=1}^{e-1} i^2 < m \right \}`](Eqn_1_2_1.gif)

Utilisez le *stub* `hoFitSquares` pour votre version.

### 1.2.2 : Mot représentatif *[3 points]*

`recRepresentativeWord` prend une liste de mots en paramètre et
retourne le mot avec le plus grand nombre d'occurrences de la lettre
la plus fréquente dans tout le texte. La lettre la plus fréquente est
choisie sans considérer la casse, et si deux lettre apparaîssent le
même nombre de fois, on choisit la première en ordre
alphabétique. Similairement, si plusieurs mots contiennent la lettre
choisie le même nombre de fois, on choisira le premier en ordre
lexicographique (où les lettre majuscules viennent avant les
minuscules).

L'implantation donnée n'est pas lisible, mais fonctionne comme
référence. Suivez la description ci-dessus pour vous guider.

Utilisez le *stub* `hoRepresentativeWord` pour votre version.

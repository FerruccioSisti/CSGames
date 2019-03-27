# Le langage le plus pur

  Un livre sacré décrivant le langage le plus pur, le Lambda Calcul, a
été découvert sur une île déserte. Malheureusement, certaines parties
ont été laissées en exercice au lecteur, une pratique courante dans
les Saintes Écriture de la PF. Vous devrez compléter les exercices
suivant pour démontrer vos habilités.

## Lambda Calcul

  Le [Lambda-calcul] est un système formel, qui, en plus d'être
Turing-complet, reste assez simple. En effet, le langage abstrait
n'est composé que de trois type d'expressions. Voici la définition du
type de donnée correspondant, pris directement du fichier
`Language.hs`:

```haskell
type Symbol = String
data Expr = Var Symbol
          | Lambda Symbol Expr
          | App Expr Expr
```

  On peut y voir qu'une lambda expression est soit une variable
(identifiée par un symbole qui est une chaîne de caractères), soit une
lambda-abstraction, ou une application. Une lambda-abstraction est
essentiellement une définition de fonction anonyme, qui lie un symbole
à un argument qui peut être utiliser dans la
sous-expression. L'application, quant-à-elle, est construite avec deux
sous-expressions: la fonction et l'argument. Pendant l'évaluation, la
fonction est d'abord réduite à une lambda-abstraction, puis appliquée
en substituant, dans le corps de l'abstraction, le symbole lié par
l'expression fournie en argument. Par exemple, le terme `Lambda "x"
(Var "x")` représente la fonction d'identité. `Lambda "a" (Lambda "b"
(App (Var "a") (Var "b")))` est une fonction qui prend deux arguments
et applique le premier au second (chaque abstraction ne prend qu'un
argument, mais conceptuellement, cette expression peut être appliquée
deux fois).

  L'utilité du lambda-calcul vient du fait qu'il s'agit d'une bonne
abstraction pour les programmes, étant à la fois simple, composable,
et Turing-complète. C'est un concept largement utilisé dans le domaine
de la théorie des langages de programmation, grâce à sa
[correspondance aux preuves] qui permet le développement de systèmes
de types utiles et de programmes plus fiables.

[Lambda-Calcul]: https://fr.wikipedia.org/wiki/Lambda-calcul
[correspondance aux preuves]: https://fr.wikipedia.org/wiki/Correspondance_de_Curry-Howard

## Lambdastic

  Pour les exercices qui suivent, vous travaillerez avec un langage de
lambda-calcul qui a été nommé avec beaucoup d'enthousiasme:
`Lambdastic`. Un parseur, un *pretty-printer*, et un interpréte
interactif ont déjà été écrits.

### Syntaxe concrète

  - Les variables commencent par une lettre et peuvent contenir des
    lettres, chiffres, *underscore* et le guillemet simple.
  - La syntaxe pour l'abstraction est la suivante: `\x -> expr`.
  - La syntaxe pour l'application est la suivante: `$ fun arg`.
  - La syntaxe pour les assignations est `identifiant = expr`. Il
    s'agit d'un très simple système de macros. L'identifiant n'est lié
    qu'après l'assignation. Par conséquent, il est incorrect d'écrire
    `x = x`. Cette limitation ne permet pas de faire de la récursion
    directement. Cependant, il est possible de définir une fonction
    récursive en utilisant la fonction `fix`, comme nous le verrons
    plus loin.
  - De plus, il y a une syntaxe pour des modules et l'importation de
    ceux-cis pour notre système de macros. Cela nous permet d'utiliser
    des macros définies dans d'autres fichiers.
  - Les énoncés de module, d'importation et d'assignation sont séparés
    par `.` (un point).
  - Il y a du sucre syntaxique pour l'abstraction/application avec
    plusieurs paramètres à la fois: `\ a b c -> expr` est l'équivalent
    de `\ a -> \ b -> \ c -> expr`. `$ a b c` est l'équivalent de `$
    ($ a b) c`. *Malheureusement, cela rend difficile la lecture pour
    voir quels argument appartiennent à quelles applications, utilisez
    généreusement les parenthèses!*
  - Il y a aussi du sucre syntaxique pour les expressions `let`:`let
    x=exprx, y=expry in exprz` se transforme pour devenir `$ (\ x ->
    ($ (\ y -> exprz) expry)) exprx`.
  - `--` débute un commentaire de ligne, `{-` et `-}` englobent des
    commentaires sur plusieurs lignes, comme en Haskell.

  Jetez un coup d'oeil au fichiers `*.lam` pour voir des exemples.

### Structure du projet

  Le projet a la structure suivante:

1. Le répertoire `lib` contient le noyau de l'implantation du langage:
  - `Language.hs` contient les types de données au coeur du langage.
  - `Evaluation.hs` contient des *stubs* pour les fonctions
    d'évaluation que vous aurez à compléter.

2. Le répertoire `src` contient le code pour l'interpréte interactif.

3. `test` contient plusieurs tests.

4. Les fichiers `*.lam` sont des exemple de code Lamdastic.
   - `base.lam` définit un ensemble de fonctions de base que vous
     pourrez utiliser dans le reste de votre code Lambdastic. On y
     retrouve principalement les définitions correspondant *Church
     encoding* des types de données comme les booléens, les entiers et
     les listes.
   - `eval.lam` et `lib.lam` contiennent des *stubs* de fonction que
     vous aurez à compléter.

## Guide d'utilisation

Les tests pour le code Haskell peuvent être lancés avec la commande:

```
$ cabal new-test
```

Il est possible de restreindre les tests:

```
$ cabal new-run test -- --pattern <pattern>
```

Pour lancer l'interprète, écrivez:

```
$ cabal new-run lambdastic
$ # you can also import ".lam" files from the start :
$ cabal new-run lambdastic -- base.lam lib.lam
```
Voici une brève démonstration des fonctionnalités de l'interprète.

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

# Exercices

## 1. Complétez les fonctions d'évaluation [10 points]

Pour cet exercice, vous devez implanter deux stratégies d'évaluation
pour notre langage: *call by value* et *call by name*. Les
lambda-expressions sont réduites en faisant la beta-réduction: quand
une lambda-abstraction est appliquée, la beta-réduction substitue
toutes les occurences du symbole lié dans le corps de l'abstraction
par l'argument. Par exemple, le terme `$ (\ x -> $ x x) y` est
beta-réduit à `$ y y`. S'il y a plusieurs redex (expression
réductibles) dans une expression, une stratégie d'évaluation dicte
l'ordre dans lequel elles seront effectuées.

Pour plus de détails, consultez l'[article
wiki](https://en.wikipedia.org/wiki/Lambda_calculus#Beta_reduction). Notez
qu'on évite les problèmes d'alpha-renommage en utilisant une fonction
de substitution qui prend en compte les règles de portée des symboles (`substitute` dans `lib/Language.hs`).

Dans `lib/Evaluation.hs`, complétez les fonctions
`evalStepsCallByName` et `evalStepsCallByValue`. Ces deux fonctions
prennent un lambda-expression et retournent la liste des expressions
correspondant aux étapes de réduction, en ordre. La dernière
expression dans la liste n'est donc pas réductible dans la stratégie
appliquée. La première expression de la liste est toujours celle de
départ. De cette façon, la liste n'est jamais vide et contient la
réponse comme dernier élément.

Pour les deux stratégies à implanter (mais pas pour la stratégie
"normal", déjà implantée) les lambda-abstraction ne sont pas
réductibles. Autrement dit, ces stratégies ne vont pas "rentrer à
l'intérieur" du corps d'une abstraction, même si celui-ci contient des
redex.

La stratégie `CallByName` béta-réduit l'application la plus à gauche
dont la fonction est une abstraction. En d'autres mots, pour une
application donnée, on réduit d'abord la fonction, puis on béta-réduit
l'application, même si les arguments n'ont pas été réduits.

La stratégie `CallByValue` commence aussi par réduire la fonction,
puis les arguments, et finalement fait la béta-réduction. Cette
stratégie est dite "stricte" parce que les arguments sont toujours
évalués, même si ils ne sont pas utilisés dans le corps d'une
fonction.

`test/TestEval.hs` contient des exemples d'étapes de réduction pour
chacune des stratégies à implanter.

## 2. Un terme très spécial [10 points]

Pour certaines lambda expressions et certaines stratégies,
l'évaluation ne termine jamais. Par exemple, le terme `omega` dans `base.lam` "diverge" pour toutes les stratégies du projet.

En utilisant `omega`, trouvez un terme pour lequel l'évaluation
termine dans un des deux ordres que vous avez implanté, et qui diverge
pour l'autre stratégie. Assignez votre terme à l'identifiant `diverges_in_one_order` dans le fichier `eval.lam`.

## 3. Écrivez vos propres fonctions Lambdastic! [20 points]

Complétez les fonctions dans `lib.lam`. Utilisez les définitions
provenant de `base.lam` et consultez l'article de wiki explicant le
[Church encoding](https://en.wikipedia.org/wiki/Church_encoding), au
besoin.

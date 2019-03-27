module TestEval where

import Test.Tasty.HUnit (Assertion, (@?), assertFailure)
import Control.Monad (mapM_)
import Text.Printf (printf)
import Data.List (find)

import Evaluation
import Language
import Parser
import PrettyPrinter
import Util

checkSteps :: EvalStrategy -> [Expr] -> Assertion
checkSteps strategy expectedSteps =
  let
    actualSteps = steps strategy $ head expectedSteps
    n = length expectedSteps
    w = 80
  in
    case
      find (\(_, e, a) -> e /= a) (zip3 [1..] expectedSteps actualSteps)
    of
      Just (i, e, a) ->
        assertFailure $
        (printf ("Wrong step #%d for strategy %s.\n"
                ) i (strategyName strategy)) ++
        (printf ("Common steps :\n%s\n"
                ) $
         unlines $ showIntermediates w $ take (i - 1) expectedSteps) ++
        (printf ("Expected next step :\n%s\n"
                ) $ showExpr w (expectedSteps !! (i - 1))) ++
        (printf ("Actual next step :\n%s\n"
                ) $ showExpr w (actualSteps !! (i - 1)))
      Nothing ->
        case () of
          _ | lengthAtLeast (n + 1) actualSteps ->
              assertFailure $
              (printf ("Wrong step for strategy %s.\n"
                      ) (strategyName strategy)) ++
              (printf ("Common steps :\n%s\n"
                      ) $ unlines $ showIntermediates w actualSteps) ++
              "Last common step is expected not to be reducible.\n" ++
              (printf ("Actual next step :\n%s\n"
                      ) $ showExpr w (actualSteps !! n))
          _ | not (lengthAtLeast n actualSteps) ->
              let l = length expectedSteps in
                assertFailure $
                (printf ("Wrong step for strategy %s.\n"
                        ) (strategyName strategy)) ++
                (printf ("Common steps :\n%s\n"
                        ) $
                 unlines $ showIntermediates w expectedSteps) ++
                (printf ("Expected next step :\n%s\n"
                        ) $ showExpr w (last expectedSteps)) ++
                "Actual next step not produced.\n"
          otherwise ->
            return ()

unit_check_evalCallByName =
  mapM_ (checkSteps callByName) . map (map readExpr) $
  [ [ "\\x -> x" ]
  , [ "$ (\\a b c -> a)" ++
      "  ($ (\\ f s -> f) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\ b c -> ($ (\\ f s -> f) (\\ a b -> b) (\\ a b -> a)))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\ c -> ($ (\\ f s -> f) (\\ a b -> b) (\\ a b -> a)))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\ f s -> f) (\\ a b -> b) (\\ a b -> a)",
      "$ (\\ s -> (\\ a b -> b)) (\\ a b -> a)",
      "(\\ a b -> b)"
    ]
  , [ "$ (\\x -> x)" ++
      "  (\\ a b c -> $ c c b a)" ++
      "  (\\ a b c -> a)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ a b c -> $ c c b a)" ++
      "  (\\ a b c -> a)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ b c -> $ c c b (\\ a b c -> a))" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ c -> $ c c (\\ a b c -> b) (\\ a b c -> a))" ++
      "  (\\ a b c -> c)"
    , "$ (\\ a b c -> c)" ++
      "  (\\ a b c -> c)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> a)"
    , "$ (\\ b c -> c)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> a)"
    , "$ (\\ c -> c)" ++
      "  (\\ a b c -> a)"
    , "\\ a b c -> a"
    ]
  , [ "\\f -> $ (\\y -> $ y y) (\\z -> $f ($ z z))" ]
  ]

unit_check_evalCallByValue =
  mapM_ (checkSteps callByValue) . map (map readExpr) $
  [ [ "\\x -> x" ]
  , [ "$ (\\a b c -> a)" ++
      "  ($ (\\ f s -> f) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\a b c -> a)" ++
      "  ($ (\\ s -> (\\ a b -> b)) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\a b c -> a)" ++
      "  (\\ a b -> b)" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\b c -> (\\ a b -> b))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\b c -> (\\ a b -> b))" ++
      "  ($ (\\ s -> s) (\\ a b -> a))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\b c -> (\\ a b -> b))" ++
      "  (\\ a b -> a)" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\c -> (\\ a b -> b))" ++
      "  ($ (\\ f s -> s) (\\ a b -> b) (\\ a b -> a))",
      "$ (\\c -> (\\ a b -> b))" ++
      "  ($ (\\ s -> s) (\\ a b -> a))",
      "$ (\\c -> (\\ a b -> b))" ++
      "  (\\ a b -> a)",
      "(\\ a b -> b)"
    ]
  , [ "$ (\\x -> x)" ++
      "  (\\ a b c -> $ c c b a)" ++
      "  (\\ a b c -> a)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ a b c -> $ c c b a)" ++
      "  (\\ a b c -> a)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ b c -> $ c c b (\\ a b c -> a))" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> c)"
    , "$ (\\ c -> $ c c (\\ a b c -> b) (\\ a b c -> a))" ++
      "  (\\ a b c -> c)"
    , "$ (\\ a b c -> c)" ++
      "  (\\ a b c -> c)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> a)"
    , "$ (\\ b c -> c)" ++
      "  (\\ a b c -> b)" ++
      "  (\\ a b c -> a)"
    , "$ (\\ c -> c)" ++
      "  (\\ a b c -> a)"
    , "\\ a b c -> a"
    ]
  , [ "\\f -> $ (\\y -> $ y y) (\\z -> $f ($ z z))" ]
  ]

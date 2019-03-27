module TestUtil where

import Test.QuickCheck.Property
import Test.Tasty.HUnit

data Function a b = Function String (a->b)

fn n f = Function n f

compareFunctions_qc ::
  (Show a, Eq b, Show b) => Function a b -> Function a b -> a -> Property
compareFunctions_qc (Function faName fa) (Function fbName fb) input =
  counterexample ("Calls to " ++ show faName ++ " and " ++ show fbName ++
                   " with argument " ++ show input ++ " return different values.") $
  (fa input) === (fb input)

testFunction_qc ::
  (Show a, Eq b, Show b) => Function a b -> a -> b -> Property
testFunction_qc (Function fname f) arg expected =
  counterexample ("Call to " ++ show fname ++ " with argument " ++ show arg ++
                 " returned " ++ show (f arg) ++ " instead of " ++
                 show expected ++ ".") $
  f arg == expected

testFunction_hunit ::
  (Show a, Eq b, Show b, HasCallStack) => Function a b -> a -> b -> Assertion
testFunction_hunit (Function fname f) arg expected =
  assertBool ("Call to " ++ show fname ++ " with argument " ++ show arg ++
              " returned " ++ show (f arg) ++ " instead of " ++
              show expected ++ ".") (f arg == expected)

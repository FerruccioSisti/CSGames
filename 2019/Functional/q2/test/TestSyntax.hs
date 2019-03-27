module TestSyntax where

import Test.QuickCheck as QC

import qualified Data.Map.Strict as M
import Control.Monad
import Data.List

import Modules (substituteMacros)
import Language
import PrettyPrinter
import Parser

prop_parse_prettyprinted_is_id :: QC.Property
prop_parse_prettyprinted_is_id =
  forAll arbitrary (
  \expr ->
    Right expr == parseExpr (renderStr 80 $ prettyExpr expr)
  )

instance Arbitrary Expr where
  arbitrary = arbitraryExpr False
  shrink (Var _) = []
  shrink a@(App (Lambda sym sub) arg) =
    [substituteMacros (M.singleton sym arg) sub] ++ shrinkApp a
  shrink (Lambda sym sub) =
    let
      recur = Lambda sym <$> shrink sub
    in
      case unboundSymbols sub of
        [] -> return sub ++ recur
        [sym] -> recur
        xs ->
          (++ recur) $
          do
            r <- delete sym xs
            return $ substituteMacros (M.singleton sym (Var r)) sub
  shrink a@(App _ _) =
    shrinkApp a

shrinkApp (App fun arg) =
  [fun, arg] ++ liftM2 App (shrink fun) (shrink arg)

arbitrarySymbol =
  liftM2 (:) start (listOf rest) `suchThat` notReserved
  where
    notReserved = not . (`elem` reservedIdents)
    start = elements letter
    rest = elements $ alphanum <> "_'"
    alphanum = letter <> ['0'..'9']
    letter = ['a'..'z']

arbitraryExpr :: Bool -> Gen Expr
arbitraryExpr allowUnboundVars =
    sized (arbitrary' [])
    where
      chooseIdent inScope =
        if allowUnboundVars then arbitrarySymbol else elements inScope

      arbitrary' inScope n | n < 0 = Var <$> chooseIdent inScope
      arbitrary' [] n = arbitraryLambda [] n
      arbitrary' inScope n =
        oneof [ Var <$> chooseIdent inScope
              , arbitraryLambda inScope n
              , do
                  let makeSubExpr = arbitrary' inScope (n `div` 2)
                  liftM2 App makeSubExpr makeSubExpr
              ]

      arbitraryLambda inScope n =
        do
          newSymbol <- arbitrarySymbol
          subExpr <- arbitrary' (newSymbol:inScope) (n-1)
          return $ Lambda newSymbol subExpr

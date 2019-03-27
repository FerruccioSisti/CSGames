module Language where

import qualified Data.Set as S
import Data.List (elemIndex)
import Data.Function (on)

-- Core language
type Symbol = String
data Expr = Var Symbol
          | Lambda Symbol Expr
          | App Expr Expr
          deriving (Eq, Ord, Show)
type Assignment = (Symbol, Expr)

makeNestedLambda :: [Symbol] -> Expr -> Expr
makeNestedLambda vars sub =
  foldr Lambda sub vars

makeNestedApp :: Expr -> [Expr] -> Expr
makeNestedApp fun args =
  foldr (flip App) fun $ reverse args

makeLet :: [Assignment] -> Expr -> Expr
makeLet assigns sub =
  foldr step sub assigns
  where
    step (lhs, rhs) e = Lambda lhs e `App` rhs

unnestLambda :: Expr -> ([Symbol], Expr)
unnestLambda =
  unnestLambda' []
  where
    unnestLambda' syms (Lambda sym sub) =
      unnestLambda' (sym:syms) sub
    unnestLambda' syms expr =
      (reverse syms, expr)

unnestApp :: Expr -> (Expr, [Expr])
unnestApp =
  unnestApp' []
  where
    unnestApp' args (App fun arg) =
      unnestApp' (arg:args) fun
    unnestApp' args expr =
      (expr, args)

unboundSymbols :: Expr -> [Symbol]
unboundSymbols e =
  S.toList $ unboundSymbols' e
  where
    unboundSymbols' (Var s) =
      S.singleton s
    unboundSymbols' (Lambda s sub) =
      S.delete s $ unboundSymbols' sub
    unboundSymbols' (App fun arg) =
      unboundSymbols' fun <> unboundSymbols' arg

noUnbound :: Expr -> Bool
noUnbound = null . unboundSymbols

-- Capture avoiding substitution.
-- 1st argument: The symbol to substitute.
-- 2nd argument: The expression to substitute the symbol with.
-- 3rd argument: The expression in which the substitution should occur.
substitute :: Symbol -> Expr -> Expr -> Expr
substitute sym val var@(Var sym')
  | sym == sym' = val
  | otherwise = var
substitute sym val lam@(Lambda sym' sub)
  | sym == sym' = lam -- lam rebinds sym
  | sym' `elem` unboundSymbols val =
    -- sym' is not "fresh"
    -- substitute sym' in lam with a new name and try again
    let newsym = sym' ++ "'" in
      substitute sym val $
      (Lambda newsym $ substitute sym' (Var newsym) sub)
  | otherwise = Lambda sym' $ substitute sym val sub
substitute sym val (App fun arg) =
  App (substitute sym val fun) (substitute sym val arg)

-- In order to verify alpha-equivalence, we compare the De Bruijn
-- representation of the lambda terms

data DeBruijn = BVar Int
              | BFree Symbol
              | BLambda DeBruijn
              | BApp DeBruijn DeBruijn
  deriving (Eq, Ord, Show)

deBruijn :: Expr -> DeBruijn
deBruijn = deBruijn' []
  where
    deBruijn' env (Var sym) =
      maybe (BFree sym) BVar $ elemIndex sym env
    deBruijn' env (Lambda sym sub) =
      BLambda $ deBruijn' (sym:env) sub
    deBruijn' env (App fun arg) =
      BApp (deBruijn' env fun) (deBruijn' env arg)

alphaEquiv :: Expr -> Expr -> Bool
alphaEquiv = (==) `on` deBruijn

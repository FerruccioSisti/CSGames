module Evaluation
  ( EvalStrategy (..)
  , callByName
  , callByValue
  , normal
  , eval
  , evalStrategies
  , evalStepsCallByName
  , evalStepsCallByValue
  , evalStepsNormal
  , toInt
  ) where

import Control.Applicative
import Data.Maybe

import Language

data EvalStrategy =
  EvalStrategy
  { strategyName :: String
  , steps :: (Expr -> [Expr])
  }

instance Show EvalStrategy where
  show = strategyName

callByName :: EvalStrategy
callByName = EvalStrategy "CallByName" evalStepsCallByName

callByValue :: EvalStrategy
callByValue = EvalStrategy "CallByValue" evalStepsCallByValue

normal :: EvalStrategy
normal = EvalStrategy "Normal" evalStepsNormal

evalStrategies :: [EvalStrategy]
evalStrategies = [callByName, callByValue, normal]

eval :: EvalStrategy -> Expr -> Expr
eval s = last . steps s

evalStepsCallByName :: Expr -> [Expr]
evalStepsCallByName =
  return -- TODO compute the evaluation step for the call-by-name
         -- strategy

evalStepsCallByValue :: Expr -> [Expr]
evalStepsCallByValue =
  return -- TODO compute the evaluation step for the call-by-name
         -- strategy

evalStepsNormal :: Expr -> [Expr]
evalStepsNormal =
  catMaybes . takeWhile isJust . iterate (>>= step) . pure
  where
    step (App (Lambda sym sub) arg) =
      Just $ substitute sym arg sub -- beta-reduction
    step (App fun arg) =
      (`App` arg) <$> step fun <|> App fun <$> step arg
    step (Lambda sym sub) =
      Lambda sym <$> step sub
    step _ =
      Nothing -- Term is stuck

toInt :: Expr -> Maybe Int
toInt expr =
  case last $ evalStepsNormal expr of
    Lambda _ (Lambda _ sub) ->
      count sub 0
    _ ->
      Nothing
  where
    count (App _ rest) i = count rest (i + 1)
    count (Var _) i = Just i
    count _ _ = Nothing

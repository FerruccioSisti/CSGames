{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module TestRecursion where

import Test.Tasty.HUnit
import Test.QuickCheck as QC
import Test.SmallCheck.Series as S

import TestUtil as U
import Recursion

unit_recFibonacci =
  checkFib (fn "recFibonacci" recFibonacci)

unit_tailRecFibonacci =
  checkFib (fn "tailRecFibonacci" tailRecFibonacci)

checkFib fibfn =
  mapM_ (checkFib' fibfn) $ zip [0..10] [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]

checkFib' fibfn (input, expected) =
  testFunction_hunit fibfn input expected

newtype SmallInt = SmallInt {getInt :: Int}
  deriving (Eq, Ord, Show, Num, Integral, Real, Enum)

instance Bounded SmallInt where
  minBound = 0
  maxBound = 30

instance Arbitrary SmallInt where
  arbitrary =
    let
      bounds = (fromIntegral (minBound :: SmallInt),
                fromIntegral (maxBound :: SmallInt))
    in
      fmap SmallInt (QC.choose bounds :: Gen Int) 

prop_recFibonacci_and_tailRecFibonacci_same :: SmallInt -> QC.Property
prop_recFibonacci_and_tailRecFibonacci_same n =
  let
    n' = getInt n
    recfn = fn "recFibonacci" recFibonacci
    tailrecfn = fn "tailRecFibonacci" tailRecFibonacci
  in
    compareFunctions_qc recfn tailrecfn n'

prop_recFizzBuzz_and_tailRecFizzBuzz_same :: SmallInt -> QC.Property
prop_recFizzBuzz_and_tailRecFizzBuzz_same n =
  let
    n' = getInt n
    recfn = fn "recFizzBuzz" recFizzBuzz
    tailrecfn = fn "tailRecFizzBuzz" tailRecFizzBuzz
  in
    compareFunctions_qc recfn tailrecfn n'

checkExpSc ::
  (Integer -> Integer -> Integer -> Integer) ->
  Integer -> S.NonNegative Integer -> S.Positive Integer -> Bool
checkExpSc f b e s =
  f b e' s' == b ^ e'
  where
    e' = S.getNonNegative e
    s' = S.getPositive s

scprop_recExp_small = checkExpSc recExp
scprop_tailRecExp_small = checkExpSc tailRecExp

checkExpQc ::
  U.Function (Integer, Integer, Integer) Integer ->
  Integer -> QC.NonNegative Integer -> QC.Positive Integer -> Property
checkExpQc f b e s =
  testFunction_qc f (b,e',s') (b ^ e')
  where
    e' = QC.getNonNegative e
    s' = QC.getPositive s

uncurry3 f (a,b,c) = f a b c

prop_recExp = checkExpQc $ fn "recExp" $ uncurry3 recExp
prop_tailRecExp = checkExpQc $ fn "tailRecExp" $ uncurry3 tailRecExp

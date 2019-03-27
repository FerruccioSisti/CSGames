module Recursion where

recFibonacci :: Int -> Int
recFibonacci 0 = 0
recFibonacci 1 = 1
recFibonacci n = recFibonacci (n-1) + recFibonacci (n-2)

tailRecFibonacci :: Int -> Int
tailRecFibonacci n = 0 -- TODO Write this function

recFizzBuzz :: Int -> [String]
recFizzBuzz 0 = []
recFizzBuzz n =
  recFizzBuzz (n - 1)
  ++
  [ case n of it | (3*5) `divides` it -> "FizzBuzz"
                 | 3 `divides` it -> "Fizz"
                 | 5 `divides` it -> "Buzz"
                 | otherwise -> show it
  ] where a `divides` b = b `mod` a == 0

tailRecFizzBuzz :: Int -> [String]
tailRecFizzBuzz n = [] -- TODO Write this function

-- O(n) exponentiation helper for small exponents
simpleExp :: Integer -> Integer -> Integer
simpleExp base expon = product $ replicate (fromIntegral expon) base

recExp :: Integer -> Integer -> Integer -> Integer
recExp _ 0 _ = 1
recExp base 1 _ = base
recExp base expon 1 = base `simpleExp` expon
recExp base expon step =
  let
    (d, m) = expon `divMod` step
    recursivePart = recExp (base `simpleExp` step) d step
    remainderPart = base `simpleExp` m
  in
     recursivePart * remainderPart

tailRecExp :: Integer -> Integer -> Integer -> Integer
tailRecExp base expon step = 0 -- TODO write this function

module Util where

allExceptLast :: [a] -> [a]
allExceptLast [] = []
allExceptLast [_] = []
allExceptLast (x:xs) = (x:allExceptLast xs)

splitAtLast :: [a] -> ([a], a)
splitAtLast [] = undefined
splitAtLast [x] = ([], x)
splitAtLast (x:xs) =
  let (ls, last') = splitAtLast xs in
    (x:ls, last')
  
lengthAtLeast :: Int -> [a] -> Bool
lengthAtLeast 0 = const True
lengthAtLeast n = not . null . drop (n-1)


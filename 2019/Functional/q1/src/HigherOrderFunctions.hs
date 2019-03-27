module HigherOrderFunctions where

import Data.Char
import Data.List

recFitSquares :: Integer -> Integer
recFitSquares m =
  recFitSquares' 0 1
  where
    recFitSquares' s i
      | s + i ^ 2 >= m = i
      | otherwise = recFitSquares' (s + i^2) (i + 1)

hoFitSquares :: Integer -> Integer
hoFitSquares m = 0 -- TODO write this function

recRepresentativeWord :: [String] -> String
recRepresentativeWord wordlist =
  mostOccurences wordlist $ mostFreqLetter . sort . map toLower $ concat wordlist
  where
    mostFreqLetter (l:ls) = mostFreqLetter' 0 ' ' 1 l ls
    mostFreqLetter [] = undefined
    mostFreqLetter' countMax letterMax countLast letterLast (l:ls)
      | letterLast == l =
          mostFreqLetter' countMax letterMax (countLast+1) l ls
      | countLast > countMax =
          mostFreqLetter' countLast letterLast 1 l ls
      | otherwise = mostFreqLetter' countMax letterMax 1 l ls
    mostFreqLetter' countMax letterMax countLast letterLast [] =
      if countLast > countMax then letterLast else letterMax

    mostOccurences ws c =
      mostOccurences' 0 "" (reverse $ sort ws) c
    mostOccurences' iPrev wPrev (w:ws) c
      | iPrev > occurences w c = mostOccurences' iPrev wPrev ws c
      | otherwise = mostOccurences' (occurences w c) w ws c
    mostOccurences' _ wPrev [] _ = wPrev

    occurences ls c = occurences' ls c 0
    occurences' (l:ls) c i | toLower l == c = occurences' ls c (i+1)
                           | otherwise = occurences' ls c i
    occurences' [] _ i = i
    
hoRepresentativeWord :: [String] -> String
hoRepresentativeWord ws = [] -- TODO write this function

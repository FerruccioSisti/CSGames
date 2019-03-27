module TestHigherOrderFunctions where

import Test.Tasty.HUnit
import Test.QuickCheck as QC
import Test.SmallCheck.Series as S

import TestUtil as U
import HigherOrderFunctions

check_fitSquares f m =
  sum (map (^2) [1..(f m)]) >= m &&
  sum (map (^2) [1..(f m) - 1]) < m

check_fitSquares_qc (Function fname f) m =
  let
    notTooSmall =
      counterexample (fname ++ " " ++ show m ++ " returned " ++ show (f m) ++
                      " which is too small because the next sum fits.") $
      sum (map (^2) [1..(f m)]) >= m
    notTooBig =
      counterexample (fname ++ " " ++ show m ++ " returned " ++ show (f m) ++
                      " which is too large because the sum is larger or equal to m.") $
      sum (map (^2) [1..(f m) - 1]) < m
  in
    notTooSmall .&&. notTooBig

scprop_recFitSquares_small :: S.Positive Integer -> Bool
scprop_recFitSquares_small = check_fitSquares recFitSquares . S.getPositive

prop_recFitSquares :: QC.Positive Integer -> Property
prop_recFitSquares =
  check_fitSquares_qc (fn "recFitSquares" recFitSquares) . QC.getPositive

scprop_small_hoFitSquares :: S.Positive Integer -> Bool
scprop_small_hoFitSquares = check_fitSquares hoFitSquares . S.getPositive

prop_hoFitSquares :: QC.Positive Integer -> Property
prop_hoFitSquares =
  check_fitSquares_qc (fn "hoFitSquares" hoFitSquares) . QC.getPositive

prop_recFitSquares_and_hoFitSquares_same :: QC.Positive Integer -> Property
prop_recFitSquares_and_hoFitSquares_same m =
  let
    recfn = fn "recFitSquares" recFitSquares
    hofn = fn "hoFitSquares" hoFitSquares
    arg = QC.getPositive m
  in
    compareFunctions_qc recfn hofn arg

unit_recRepresentativeWord =
  checkRepresentativeWord (fn "recRepresentativeWord" recRepresentativeWord)
unit_hoRepresentativeWord =
  checkRepresentativeWord (fn "hoRepresentativeWord" hoRepresentativeWord)

checkRepresentativeWord f =
  do
    testFunction_hunit f (words "aac aab aae aaee aazz") "aab"
    testFunction_hunit f (words "aAc AAB AaE aAEe aaZz") "AAB"
    testFunction_hunit f (translate text1) "adipiscing"
    testFunction_hunit f (translate text2) "pellentesque"

text1 =
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer imperdiet ligula rhoncus est consectetur, in pretium nisi fermentum. Suspendisse sagittis pharetra leo, vel venenatis eros fringilla nec. Mauris blandit arcu sed vestibulum finibus. Duis cursus facilisis nisl. In nec tortor fringilla tortor tincidunt mattis. Vestibulum nisi neque, venenatis non orci quis, vulputate blandit nunc. Etiam commodo in turpis a tempus."

text2 =
  "Sed felis nunc, lacinia quis elit vel, imperdiet luctus mauris. Etiam iaculis scelerisque nulla id lacinia. Phasellus sed blandit ligula. Maecenas in sapien nec urna feugiat venenatis ullamcorper ac mi. Nullam pellentesque leo eu facilisis tincidunt. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce quis neque scelerisque, egestas nisi quis, accumsan dolor. Nulla facilisi. Praesent vel nibh euismod purus iaculis lobortis. Nullam a dolor in urna ullamcorper ultricies a vitae velit. Sed ornare rutrum mi, sit amet elementum nunc lacinia vitae. Curabitur nulla velit, ultrices ut tempus non, auctor scelerisque lorem. Lorem ipsum dolor sit amet, consectetur adipiscing elit.Donec ipsum nunc, elementum eget leo bibendum, scelerisque placerat ipsum. Morbi fringilla tortor eget consectetur commodo. Cras ac sapien eu urna tincidunt mollis eget ut erat. Sed eleifend ipsum non consequat laoreet. Phasellus dapibus molestie turpis id ullamcorper. Mauris bibendum suscipit purus, eget tempus felis dignissim non. Praesent eros urna, blandit non felis eu, molestie fringilla lorem. Curabitur in nisi eu sapien viverra convallis. Quisque auctor rutrum venenatis. In quam arcu, iaculis ut facilisis quis, fermentum non erat. Quisque gravida sit amet augue sit amet vehicula."

translate =
  words .
  filter (\c -> elem c (['a'..'z'] ++ " "))

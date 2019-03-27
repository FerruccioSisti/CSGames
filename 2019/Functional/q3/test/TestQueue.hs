module TestQueue where

import Test.QuickCheck.Arbitrary
import Test.Tasty.HUnit

import Control.Monad (liftM2)
import Data.Function (on)
import Data.List (unfoldr)
import Queue

instance (Arbitrary a) => Arbitrary (Queue a) where
  arbitrary = liftM2 Queue arbitrary arbitrary

instance Eq a => Eq (Queue a) where
  (==) = (==) `on` \q -> outgoing q ++ reverse (incoming q)

prop_revrev_is_id :: Queue Int -> Bool
prop_revrev_is_id q = (reverse_queue . reverse_queue $ q) == q

prop_enqueues_then_dequeues :: [Int] -> Bool
prop_enqueues_then_dequeues ls =
  let
    after_enqueues = foldl enqueue empty ls
    after_dequeues = unfoldr dequeue after_enqueues
  in
    after_dequeues == ls

unit_dequeue_empty :: Assertion
unit_dequeue_empty =
  dequeue (empty :: Queue Int) @?= Nothing

unit_multiple_queue_ops :: Assertion
unit_multiple_queue_ops =
  let
    q0 = empty
    q1 = enqueue q0 5
    q2 = enqueue q1 4
    Just (e1, q3) = dequeue q2
    q4 = enqueue q3 3
    Just (e2, q5) = dequeue q4
    q6 = enqueue q5 2
    q7 = enqueue q6 1
    rest = (unfoldr dequeue q7)
  in
    (e1:e2:rest) @?= [5,4,3,2,1]

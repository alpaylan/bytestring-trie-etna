{-# LANGUAGE OverloadedStrings #-}
module Etna.Witnesses where

import Etna.Properties
import Etna.Result

-- | Witness for MergeByLeftBiased: left has key "a" => value should be 1.
-- Buggy mergeBy with swapped argument order in the right-epsilon case
-- causes the merge function to receive arguments in the wrong order, so
-- lookup "a" returns 2 (right-biased) instead of 1.
witness_merge_by_left_biased_case_epsilon_right :: PropertyResult
witness_merge_by_left_biased_case_epsilon_right =
    property_merge_by_left_biased
        (MergeArgs [("a", 1)] [("", 99), ("a", 2)])

-- | Symmetric witness exercising the left-epsilon branch.
witness_merge_by_left_biased_case_epsilon_left :: PropertyResult
witness_merge_by_left_biased_case_epsilon_left =
    property_merge_by_left_biased
        (MergeArgs [("", 11), ("a", 1)] [("a", 2)])

-- | Witness for DeleteSubmapRemovesAllPrefixed: prefix "a" should remove
-- both "ab" and "ac". Buggy deleteSubmap (which uses (\\_ t -> (Nothing, t))
-- instead of (\\_ _ -> (Nothing, empty))) keeps the children intact.
witness_delete_submap_removes_all_prefixed_case_two_children :: PropertyResult
witness_delete_submap_removes_all_prefixed_case_two_children =
    property_delete_submap_removes_all_prefixed
        (DelArgs [("ab", 1), ("ac", 2)] "a")

-- | Witness with deeper subtree.
witness_delete_submap_removes_all_prefixed_case_deep :: PropertyResult
witness_delete_submap_removes_all_prefixed_case_deep =
    property_delete_submap_removes_all_prefixed
        (DelArgs [("aa", 1), ("ab", 2), ("abc", 3), ("b", 4)] "a")

-- | Witness exercising mergeMaybe's (Just _, Nothing) case: the left trie
-- has a value at a key @k@ which is also an intermediate-node prefix of
-- two right-trie keys. A buggy mergeMaybe that returns Nothing in this
-- case drops the left value at @k@.
witness_merge_by_left_biased_case_left_only_at_intermediate :: PropertyResult
witness_merge_by_left_biased_case_left_only_at_intermediate =
    property_merge_by_left_biased
        (MergeArgs [("ab", 1)] [("abc", 2), ("abd", 3)])

-- | Symmetric scaffolding witness: a buggy mergeMaybe that swapped the
-- (Nothing, Just _) case to return Nothing would be caught here. The
-- modern mergeMaybe should always return Just 99 for key "xy".
witness_merge_by_left_biased_case_right_only_at_intermediate :: PropertyResult
witness_merge_by_left_biased_case_right_only_at_intermediate =
    property_merge_by_left_biased
        (MergeArgs [("xyc", 4), ("xyd", 5)] [("xy", 99)])

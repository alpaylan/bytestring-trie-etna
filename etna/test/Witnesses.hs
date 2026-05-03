module Main where

import Etna.Result    (PropertyResult(..))
import Etna.Witnesses
import System.Exit    (exitFailure, exitSuccess)

main :: IO ()
main = do
    let cases =
            [ ("witness_merge_by_left_biased_case_epsilon_right",
               witness_merge_by_left_biased_case_epsilon_right)
            , ("witness_merge_by_left_biased_case_epsilon_left",
               witness_merge_by_left_biased_case_epsilon_left)
            , ("witness_delete_submap_removes_all_prefixed_case_two_children",
               witness_delete_submap_removes_all_prefixed_case_two_children)
            , ("witness_delete_submap_removes_all_prefixed_case_deep",
               witness_delete_submap_removes_all_prefixed_case_deep)
            , ("witness_merge_by_left_biased_case_left_only_at_intermediate",
               witness_merge_by_left_biased_case_left_only_at_intermediate)
            , ("witness_merge_by_left_biased_case_right_only_at_intermediate",
               witness_merge_by_left_biased_case_right_only_at_intermediate)
            ]
    let failures =
            [ (n, msg) | (n, Fail msg) <- cases ] ++
            [ (n, "discard")       | (n, Discard) <- cases ]
    if null failures
        then exitSuccess
        else mapM_ (\(n, m) -> putStrLn (n ++ ": " ++ m)) failures >> exitFailure

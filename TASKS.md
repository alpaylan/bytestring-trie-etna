# bytestring-trie — ETNA Tasks

Total tasks: 12

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `delete_submap_keeps_children_c7caacad_1` | quickcheck | `DeleteSubmapRemovesAllPrefixed` | `witness_delete_submap_removes_all_prefixed_case_two_children` |
| 002 | `delete_submap_keeps_children_c7caacad_1` | hedgehog | `DeleteSubmapRemovesAllPrefixed` | `witness_delete_submap_removes_all_prefixed_case_two_children` |
| 003 | `delete_submap_keeps_children_c7caacad_1` | falsify | `DeleteSubmapRemovesAllPrefixed` | `witness_delete_submap_removes_all_prefixed_case_two_children` |
| 004 | `delete_submap_keeps_children_c7caacad_1` | smallcheck | `DeleteSubmapRemovesAllPrefixed` | `witness_delete_submap_removes_all_prefixed_case_two_children` |
| 005 | `merge_maybe_drops_left_only_10bfe2dd_1` | quickcheck | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_left_only_at_intermediate` |
| 006 | `merge_maybe_drops_left_only_10bfe2dd_1` | hedgehog | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_left_only_at_intermediate` |
| 007 | `merge_maybe_drops_left_only_10bfe2dd_1` | falsify | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_left_only_at_intermediate` |
| 008 | `merge_maybe_drops_left_only_10bfe2dd_1` | smallcheck | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_left_only_at_intermediate` |
| 009 | `mergeby_arg_order_68ef3934_1` | quickcheck | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_epsilon_right` |
| 010 | `mergeby_arg_order_68ef3934_1` | hedgehog | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_epsilon_right` |
| 011 | `mergeby_arg_order_68ef3934_1` | falsify | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_epsilon_right` |
| 012 | `mergeby_arg_order_68ef3934_1` | smallcheck | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_epsilon_right` |

## Witness Catalog

- `witness_delete_submap_removes_all_prefixed_case_two_children` — deleting prefix "a" from {ab,ac} must leave the trie empty of any "a*" keys
- `witness_delete_submap_removes_all_prefixed_case_deep` — deleting prefix "a" from a trie with both shallow and deep "a*" keys leaves only "b"
- `witness_merge_by_left_biased_case_left_only_at_intermediate` — mergeBy const where right has an intermediate-node prefix must keep the left's value at that prefix
- `witness_merge_by_left_biased_case_right_only_at_intermediate` — symmetric scaffolding case (passes under the bug; included so the witness suite documents the asymmetry)
- `witness_merge_by_left_biased_case_epsilon_right` — mergeBy const with right-side epsilon arc must return left's value at shared key 'a'
- `witness_merge_by_left_biased_case_epsilon_left` — symmetric case with epsilon arc on the left side

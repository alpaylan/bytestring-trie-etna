# bytestring-trie — Injected Bugs

Efficient finite map from ByteString to values, based on big-endian patricia trees (wrengr/bytestring-trie). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug.

Total mutations: 3

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `delete_submap_keeps_children_c7caacad_1` | `deleteSubmap_keeps_children` | `src/Data/Trie.hs:179` | `patch` | `c7caacad932d17dc1538dfbaec58767600741151` |
| 2 | `merge_maybe_drops_left_only_10bfe2dd_1` | `mergeMaybe_drops_left_only` | `src/Data/Trie/Internal.hs:2220` | `patch` | `10bfe2dd869420a8a1b46b22d21034cc465e5581` |
| 3 | `mergeby_arg_order_68ef3934_1` | `mergeBy_swaps_args_in_right_epsilon_case` | `src/Data/Trie/Internal.hs:2166` | `patch` | `68ef3934af3c6d7c91a4bae78cd07a44368637d8` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `delete_submap_keeps_children_c7caacad_1` | `DeleteSubmapRemovesAllPrefixed` | `witness_delete_submap_removes_all_prefixed_case_two_children`, `witness_delete_submap_removes_all_prefixed_case_deep` |
| `merge_maybe_drops_left_only_10bfe2dd_1` | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_left_only_at_intermediate`, `witness_merge_by_left_biased_case_right_only_at_intermediate` |
| `mergeby_arg_order_68ef3934_1` | `MergeByLeftBiased` | `witness_merge_by_left_biased_case_epsilon_right`, `witness_merge_by_left_biased_case_epsilon_left` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `DeleteSubmapRemovesAllPrefixed` | ✓ | ✓ | ✓ | ✓ |
| `MergeByLeftBiased` | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. deleteSubmap_keeps_children

- **Variant**: `delete_submap_keeps_children_c7caacad_1`
- **Location**: `src/Data/Trie.hs:179` (inside `deleteSubmap`)
- **Property**: `DeleteSubmapRemovesAllPrefixed`
- **Witness(es)**:
  - `witness_delete_submap_removes_all_prefixed_case_two_children` — deleting prefix "a" from {ab,ac} must leave the trie empty of any "a*" keys
  - `witness_delete_submap_removes_all_prefixed_case_deep` — deleting prefix "a" from a trie with both shallow and deep "a*" keys leaves only "b"
- **Source**: internal — Changed type of alterBy_, bugfix in deleteSubmap, more deleteSubmap tests
  > deleteSubmap was implemented as `alterBy_ (\\_ _ _ t -> (Nothing, t))` which removed the value at the prefix node but kept the entire subtrie of children intact, leaving every key beginning with the prefix still present. The fix passes `empty` as the new subtree (`alterBy_ (\\_ _ -> (Nothing, empty))`), genuinely removing all prefixed keys.
- **Fix commit**: `c7caacad932d17dc1538dfbaec58767600741151` — Changed type of alterBy_, bugfix in deleteSubmap, more deleteSubmap tests
- **Invariant violated**: For any trie t and prefix q, after `deleteSubmap q t` no key in the result starts with q.
- **How the mutation triggers**: Reverse-applying the patch replaces `(\\_ _ -> (Nothing, empty))` with `(\\_ t -> (Nothing, t))`, so the function returns the original subtree instead of an empty one. Calling `deleteSubmap "a" (fromList [("ab",1),("ac",2)])` then leaves both "ab" and "ac" in the result instead of producing the empty trie.

### 2. mergeMaybe_drops_left_only

- **Variant**: `merge_maybe_drops_left_only_10bfe2dd_1`
- **Location**: `src/Data/Trie/Internal.hs:2220` (inside `mergeMaybe`)
- **Property**: `MergeByLeftBiased`
- **Witness(es)**:
  - `witness_merge_by_left_biased_case_left_only_at_intermediate` — mergeBy const where right has an intermediate-node prefix must keep the left's value at that prefix
  - `witness_merge_by_left_biased_case_right_only_at_intermediate` — symmetric scaffolding case (passes under the bug; included so the witness suite documents the asymmetry)
- **Source**: internal — Data.Trie.Internal: Fixed another missing case bug in mergeBy. The bug is tripped when unioning two tries with epsilon keys
  > Synthetic patch in the same family as the historical missing-case bug fixed by 10bfe2dd (which factored mergeMaybe out of mergeBy). Modern mergeMaybe handles all four (Maybe a, Maybe a) combinations explicitly. We re-introduce a missing-case-style bug by making the (Just _, Nothing) case return Nothing instead of preserving the left value, so unions drop left-only entries at any internal-Branch position where the right trie has an Arc with mv=Nothing at the same key.
- **Fix commit**: `10bfe2dd869420a8a1b46b22d21034cc465e5581` — Data.Trie.Internal: Fixed another missing case bug in mergeBy. The bug is tripped when unioning two tries with epsilon keys
- **Invariant violated**: For any tries a, b and any key k present in both, `lookup k (mergeBy (\\x _ -> Just x) a b)` must equal `lookup k a`. In particular, when @a@ has @k → v@ and @b@ has @k → ⊥@ (no value, only an intermediate Branch at that key), the merged trie must still map @k → v@.
- **How the mutation triggers**: Reverse-applying the patch changes mergeMaybe's `(Just _, Nothing) -> mv0` arm into `(Just _, Nothing) -> Nothing`. Computing `mergeBy const (singleton "ab" 1) (fromList [("abc",2),("abd",3)])` then loses the "ab"=>1 entry, since the right trie has an Arc "ab" Nothing intermediate node and mergeMaybe is invoked with mv0=Just 1 / mv1=Nothing in the (True,True) recursion case.

### 3. mergeBy_swaps_args_in_right_epsilon_case

- **Variant**: `mergeby_arg_order_68ef3934_1`
- **Location**: `src/Data/Trie/Internal.hs:2166` (inside `mergeBy`)
- **Property**: `MergeByLeftBiased`
- **Witness(es)**:
  - `witness_merge_by_left_biased_case_epsilon_right` — mergeBy const with right-side epsilon arc must return left's value at shared key 'a'
  - `witness_merge_by_left_biased_case_epsilon_left` — symmetric case with epsilon arc on the left side
- **Source**: internal — Data.Trie.Internal: mergeBy argument order bugfix
  > In mergeBy's `start` helper, the right-epsilon case @start t0 (Arc k1 (Just v1) s1) | S.null k1@ recursed with the trie arguments swapped (`go s1 t0` instead of `go t0 s1`). When the merge function is non-commutative (e.g. `\\x _ -> Just x` to take the left value on conflict), this caused values to be passed to it in the wrong order whenever the right input had an epsilon entry whose subtrie shared keys with the left.
- **Fix commit**: `68ef3934af3c6d7c91a4bae78cd07a44368637d8` — Data.Trie.Internal: mergeBy argument order bugfix
- **Invariant violated**: For any tries a, b and any key k present in both, `lookup k (mergeBy (\\x _ -> Just x) a b)` must equal `lookup k a`. (Left-biased union picks the left value on conflict.)
- **How the mutation triggers**: Reverse-applying the patch swaps the order of arguments in `go t0 s1` to `go s1 t0` inside mergeBy's right-epsilon `start` arm. Calling `mergeBy (\\x _ -> Just x) (singleton "a" 1) (fromList [("",99),("a",2)])` then yields `[("",99),("a",2)]` instead of `[("",99),("a",1)]`.

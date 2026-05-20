{-# LANGUAGE OverloadedStrings #-}
module Etna.Gens.QuickCheck where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Test.QuickCheck as QC

import           Etna.Properties

-- | Bytestrings drawn from a small alphabet.  We keep the alphabet
-- modest so that random keys frequently share prefixes (the structural
-- ingredient that drives non-trivial Trie shapes and exercises every
-- internal-Branch code path of mergeBy / mergeMaybe / deleteSubmap).
-- Length 0..8 lets the generator routinely produce both the empty key
-- (epsilon) and proper-prefix relationships between keys.
genKey :: QC.Gen ByteString
genKey = QC.sized $ \n -> do
    let cap = max 0 (min 8 n)
    k <- QC.choose (0, cap)
    cs <- QC.vectorOf k
            (QC.elements [97, 98, 99, 100, 101, 102, 103, 104])  -- a..h
    pure (BS.pack cs)

genPair :: QC.Gen (ByteString, Int)
genPair = (,) <$> genKey <*> QC.choose (-1000, 1000 :: Int)

genPairs :: QC.Gen [(ByteString, Int)]
genPairs = QC.sized $ \n -> do
    let cap = max 0 (min 16 (n + 4))
    k <- QC.choose (0, cap)
    QC.vectorOf k genPair

gen_merge_by_left_biased :: QC.Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: QC.Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

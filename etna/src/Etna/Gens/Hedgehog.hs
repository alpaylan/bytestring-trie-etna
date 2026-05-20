{-# LANGUAGE OverloadedStrings #-}
module Etna.Gens.Hedgehog where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Hedgehog.Gen    as Gen
import qualified Hedgehog.Range  as Range
import           Hedgehog        (Gen)

import           Etna.Properties

-- | Bytestrings drawn from a small alphabet.  We keep the alphabet
-- modest so random keys often share prefixes (drives non-trivial Trie
-- shapes).  Length 0..8 lets the generator routinely produce both the
-- empty key (epsilon) and proper-prefix relationships between keys.
genKey :: Gen ByteString
genKey = do
    n  <- Gen.integral (Range.linear 0 8)
    cs <- Gen.list (Range.singleton n)
                   (Gen.element [97, 98, 99, 100, 101, 102, 103, 104])  -- a..h
    pure (BS.pack cs)

genPair :: Gen (ByteString, Int)
genPair = (,) <$> genKey <*> Gen.int (Range.linearFrom 0 (-1000) 1000)

genPairs :: Gen [(ByteString, Int)]
genPairs = Gen.list (Range.linear 0 16) genPair

gen_merge_by_left_biased :: Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

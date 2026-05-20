{-# LANGUAGE OverloadedStrings #-}
module Etna.Gens.Falsify where

import           Data.ByteString          (ByteString)
import qualified Data.ByteString          as BS
import qualified Data.List.NonEmpty       as NE
import qualified Test.Falsify.Generator   as F
import qualified Test.Falsify.Range       as FR

import           Etna.Properties

ne :: [a] -> NE.NonEmpty a
ne []     = error "ne: empty list"
ne (x:xs) = x NE.:| xs

-- | Bytestrings drawn from a small alphabet.  We keep the alphabet
-- modest so random keys often share prefixes (drives non-trivial Trie
-- shapes).  Length 0..8 lets the generator routinely produce both the
-- empty key (epsilon) and proper-prefix relationships between keys.
genKey :: F.Gen ByteString
genKey = do
    cs <- F.list (FR.between (0 :: Word, 8))
                 (F.elem (ne ([97, 98, 99, 100, 101, 102, 103, 104] :: [Word])))  -- a..h
    pure (BS.pack (map fromIntegral cs))

genPair :: F.Gen (ByteString, Int)
genPair = (,) <$> genKey
              <*> (fromIntegral <$> F.inRange (FR.between ((-1000) :: Int, 1000)))

genPairs :: F.Gen [(ByteString, Int)]
genPairs = F.list (FR.between (0 :: Word, 16)) genPair

gen_merge_by_left_biased :: F.Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: F.Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

{-# LANGUAGE OverloadedStrings #-}
module Etna.Gens.QuickCheck where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Test.QuickCheck as QC

import           Etna.Properties

-- | Short bytestrings drawn from {a, b, c, d}.
genKey :: QC.Gen ByteString
genKey = do
    n <- QC.choose (0, 4 :: Int)
    cs <- QC.vectorOf n (QC.elements [97, 98, 99, 100])  -- a b c d
    pure (BS.pack cs)

genPair :: QC.Gen (ByteString, Int)
genPair = (,) <$> genKey <*> QC.choose (0, 1000 :: Int)

genPairs :: QC.Gen [(ByteString, Int)]
genPairs = do
    n <- QC.choose (0, 8 :: Int)
    QC.vectorOf n genPair

gen_merge_by_left_biased :: QC.Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: QC.Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

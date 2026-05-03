{-# LANGUAGE OverloadedStrings #-}
module Etna.Gens.Hedgehog where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Hedgehog.Gen    as Gen
import qualified Hedgehog.Range  as Range
import           Hedgehog        (Gen)

import           Etna.Properties

genKey :: Gen ByteString
genKey = do
    n  <- Gen.integral (Range.linear 0 4)
    cs <- Gen.list (Range.singleton n)
                   (Gen.element [97, 98, 99, 100])
    pure (BS.pack cs)

genPair :: Gen (ByteString, Int)
genPair = (,) <$> genKey <*> Gen.int (Range.linear 0 1000)

genPairs :: Gen [(ByteString, Int)]
genPairs = Gen.list (Range.linear 0 8) genPair

gen_merge_by_left_biased :: Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

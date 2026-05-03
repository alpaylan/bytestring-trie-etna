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

genKey :: F.Gen ByteString
genKey = do
    cs <- F.list (FR.between (0 :: Word, 4))
                 (F.elem (ne ([97, 98, 99, 100] :: [Word])))
    pure (BS.pack (map fromIntegral cs))

genPair :: F.Gen (ByteString, Int)
genPair = (,) <$> genKey
              <*> (fromIntegral <$> F.inRange (FR.between (0 :: Int, 1000)))

genPairs :: F.Gen [(ByteString, Int)]
genPairs = F.list (FR.between (0 :: Word, 16)) genPair

gen_merge_by_left_biased :: F.Gen MergeArgs
gen_merge_by_left_biased = MergeArgs <$> genPairs <*> genPairs

gen_delete_submap_removes_all_prefixed :: F.Gen DelArgs
gen_delete_submap_removes_all_prefixed =
    DelArgs <$> genPairs <*> genKey

{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
module Etna.Gens.SmallCheck where

import           Data.ByteString          (ByteString)
import qualified Data.ByteString          as BS
import           Data.Word                (Word8)
import qualified Test.SmallCheck.Series   as SC

import           Etna.Properties

newtype TrieByte = TrieByte Word8 deriving (Show, Eq)

instance Monad m => SC.Serial m TrieByte where
    series = SC.cons0 (TrieByte 97)
        SC.\/ SC.cons0 (TrieByte 98)
        SC.\/ SC.cons0 (TrieByte 99)
        SC.\/ SC.cons0 (TrieByte 100)

instance Monad m => SC.Serial m ByteString where
    series = do
        bs <- SC.series :: Monad m => SC.Series m [TrieByte]
        pure (BS.pack [b | TrieByte b <- bs])

series_merge_by_left_biased :: Monad m => SC.Series m MergeArgs
series_merge_by_left_biased = SC.cons2 MergeArgs

series_delete_submap_removes_all_prefixed
    :: Monad m => SC.Series m DelArgs
series_delete_submap_removes_all_prefixed = SC.cons2 DelArgs

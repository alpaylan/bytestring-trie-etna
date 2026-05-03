{-# LANGUAGE OverloadedStrings #-}
module Etna.Properties
    ( MergeArgs(..)
    , DelArgs(..)
    , property_merge_by_left_biased
    , property_delete_submap_removes_all_prefixed
    , buildTrie
    ) where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import           Data.List       (foldl', nub, sort)
import qualified Data.Trie       as T

import           Etna.Result

newtype Pairs = Pairs { unPairs :: [(ByteString, Int)] }
    deriving (Eq)
instance Show Pairs where
    show (Pairs ps) = show ps

data MergeArgs = MergeArgs
    { mLeft  :: [(ByteString, Int)]
    , mRight :: [(ByteString, Int)]
    } deriving (Show, Eq)

data DelArgs = DelArgs
    { dEntries :: [(ByteString, Int)]
    , dPrefix  :: ByteString
    } deriving (Show, Eq)

buildTrie :: [(ByteString, Int)] -> T.Trie Int
buildTrie = foldl' (\t (k, v) -> T.insert k v t) T.empty

normalise :: [(ByteString, Int)] -> [(ByteString, Int)]
normalise xs =
    let dedup = foldr (\(k,_) acc -> if any (\(k',_) -> k == k') acc then acc else
                                       case lookup k xs of
                                         Just v  -> (k,v):acc
                                         Nothing -> acc) [] xs
    in sort dedup

-- | Property: @mergeBy (\\x _ -> Just x)@ is left-biased.
-- For every key @k@, @lookup k (unionL a b)@ equals @lookup k a@ when @k@
-- is in @a@, otherwise @lookup k b@.
property_merge_by_left_biased :: MergeArgs -> PropertyResult
property_merge_by_left_biased (MergeArgs ls rs) =
    let a       = buildTrie ls
        b       = buildTrie rs
        merged  = T.mergeBy (\x _ -> Just x) a b
        keys    = nub (map fst (normalise ls) ++ map fst (normalise rs))
        check k =
            let actual = T.lookup k merged
                expect = case T.lookup k a of
                            Just v  -> Just v
                            Nothing -> T.lookup k b
            in if actual == expect
                 then Nothing
                 else Just (k, actual, expect)
        bads    = [b' | Just b' <- map check keys]
    in case bads of
         []        -> Pass
         (b' : _)  -> Fail $ "MergeByLeftBiased: key " ++ show (firstOf b')
                          ++ " got "      ++ show (secondOf b')
                          ++ " expected " ++ show (thirdOf b')
                          ++ " (left="  ++ show ls ++ " right=" ++ show rs ++ ")"
  where
    firstOf  (k,_,_) = k
    secondOf (_,a,_) = a
    thirdOf  (_,_,e) = e

-- | Property: @deleteSubmap q t@ removes every key beginning with @q@.
property_delete_submap_removes_all_prefixed :: DelArgs -> PropertyResult
property_delete_submap_removes_all_prefixed (DelArgs es p) =
    let t        = buildTrie es
        result   = T.deleteSubmap p t
        leftover = [ (k,v) | (k, v) <- T.toList result, BS.isPrefixOf p k ]
    in case leftover of
         [] -> Pass
         _  -> Fail $ "DeleteSubmapRemovesAllPrefixed: prefix " ++ show p
                  ++ " left over " ++ show leftover
                  ++ " (entries=" ++ show es ++ ")"


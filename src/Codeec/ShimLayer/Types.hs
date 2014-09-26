{-# Language TemplateHaskell, EmptyDataDecls, ScopedTypeVariables,
    TypeSynonymInstances, FlexibleInstances #-}

module Codeec.ShimLayer.Types (
  CacheManager(..),
  VisitedState(..),
  ResolutionState(..),
  CacheMap,
  NearestDeps,
  NearestDepsMap,
  CursorMap,
  CursorAtKey,
  Effect
) where

import qualified Data.Map as M
import qualified Data.Set as S
import Data.ByteString
import Control.Concurrent.MVar
import Database.Cassandra.CQL

import Codeec.Types

type Effect = ByteString

type CacheMap    = (M.Map (ObjType, Key) (S.Set (Addr, Effect)))
type HwmMap      = M.Map (ObjType, Key) Int
type Cache       = MVar CacheMap
type CursorAtKey = M.Map SessUUID SeqNo
type CursorMap   = (M.Map (ObjType, Key) CursorAtKey)
type Cursor      = MVar CursorMap
type NearestDepsMap = (M.Map (ObjType, Key) (S.Set Addr))
type NearestDeps = MVar NearestDepsMap
type HotLocs     = MVar (S.Set (ObjType, Key))
type Semaphore   = MVar ()
type ThreadQueue = MVar ([MVar ()])


data CacheManager = CacheManager {
  _cacheMVar      :: Cache,
  _hwmMVar        :: MVar HwmMap,
  _cursorMVar     :: Cursor,
  _depsMVar       :: NearestDeps,
  _hotLocsMVar    :: HotLocs,
  _semMVar        :: Semaphore,
  _blockedMVar    :: ThreadQueue,
  _pool           :: Pool,
  _lastGCAddrMVar :: MVar (Maybe SessUUID)
}

data VisitedState = Visited Bool  -- Boolean indicates whether the effect is resolved
                  | NotVisited (S.Set Addr)

data ResolutionState = ResolutionState {
  _keyCursor    :: M.Map SessUUID SeqNo,
  _visitedState :: M.Map Addr VisitedState
}


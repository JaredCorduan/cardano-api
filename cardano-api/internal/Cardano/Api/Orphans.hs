{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE StandaloneDeriving #-}

{-# OPTIONS_GHC -Wno-orphans #-}

module Cardano.Api.Orphans () where

import           Cardano.Binary (DecoderError (..))
import qualified Cardano.Ledger.Alonzo.Scripts as Ledger
import qualified Cardano.Ledger.Crypto as Crypto
import qualified Ouroboros.Consensus.Shelley.Ledger.Query as Consensus

import qualified Codec.Binary.Bech32 as Bech32
import qualified Codec.CBOR.Read as CBOR
import           Data.Aeson (ToJSON (..), object, pairs, (.=))
import qualified Data.Aeson as Aeson
import           Data.Data (Data)


-- FIXME: A temporary workaround for missing Eq and Data instances in plutus-ledger-api
-- TODO: remove this when plutus-ledger-api gets bumped to >=1.6.1
deriving instance Eq Ledger.CostModelApplyError
deriving instance Data Ledger.CostModelApplyError

deriving instance Data DecoderError
deriving instance Data CBOR.DeserialiseFailure
deriving instance Data Bech32.DecodingError
deriving instance Data Bech32.CharPosition

-- Orphan instances involved in the JSON output of the API queries.
-- We will remove/replace these as we provide more API wrapper types

instance Crypto.Crypto crypto => ToJSON (Consensus.StakeSnapshots crypto) where
  toJSON = object . stakeSnapshotsToPair
  toEncoding = pairs . mconcat . stakeSnapshotsToPair

stakeSnapshotsToPair :: (Aeson.KeyValue a, Crypto.Crypto crypto) => Consensus.StakeSnapshots crypto -> [a]
stakeSnapshotsToPair Consensus.StakeSnapshots
    { Consensus.ssStakeSnapshots
    , Consensus.ssMarkTotal
    , Consensus.ssSetTotal
    , Consensus.ssGoTotal
    } =
    [ "pools" .= ssStakeSnapshots
    , "total" .= object
      [ "stakeMark" .= ssMarkTotal
      , "stakeSet" .= ssSetTotal
      , "stakeGo" .= ssGoTotal
      ]
    ]

instance ToJSON (Consensus.StakeSnapshot crypto) where
  toJSON = object . stakeSnapshotToPair
  toEncoding = pairs . mconcat . stakeSnapshotToPair

stakeSnapshotToPair :: Aeson.KeyValue a => Consensus.StakeSnapshot crypto -> [a]
stakeSnapshotToPair Consensus.StakeSnapshot
    { Consensus.ssMarkPool
    , Consensus.ssSetPool
    , Consensus.ssGoPool
    } =
    [ "stakeMark" .= ssMarkPool
    , "stakeSet" .= ssSetPool
    , "stakeGo" .= ssGoPool
    ]

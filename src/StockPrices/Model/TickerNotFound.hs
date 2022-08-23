{-# LANGUAGE DeriveGeneric, DeriveAnyClass  #-}

module StockPrices.Model.TickerNotFound where

import Data.Aeson
import GHC.Generics (Generic)

newtype TickerNotFound = TickerNotFound String deriving (Generic, Show, ToJSON)
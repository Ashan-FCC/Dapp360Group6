{-# LANGUAGE DeriveGeneric, DeriveAnyClass  #-}

module StockPrices.Model.TickerNotFound where

import Data.Aeson
import GHC.Generics (Generic)

data TickerNotFound = TickerNotFound String deriving (Generic, Show, ToJSON)
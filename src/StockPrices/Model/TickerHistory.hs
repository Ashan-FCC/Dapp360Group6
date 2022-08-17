{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}

module StockPrices.Model.TickerHistory (TickerHistory(..)) where

import qualified Data.Text as T
import Data.Time
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple

data TickerHistory = TickerHistory {
        ticker          :: T.Text,
        open            :: Double,
        high            :: Double,
        low             :: Double,
        closeP          :: Double,
        adjustedClose   :: Double,
        volume          :: Double,
        date            :: Day
    } deriving (Generic, FromRow, Show)


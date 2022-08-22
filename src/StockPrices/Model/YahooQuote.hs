{-# LANGUAGE DeriveGeneric, DeriveAnyClass, OverloadedStrings  #-}

module StockPrices.Model.YahooQuote where

import Data.Aeson
import Data.Text
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple

data YahooQuote = YahooQuote {

 date :: Text,
 open :: Double,
 high :: Double ,
 low :: Double ,
 close :: Double ,
 volume :: Double ,
 adjClose :: Double
}
 deriving (Show,Generic, FromRow, ToJSON)

instance FromJSON YahooQuote
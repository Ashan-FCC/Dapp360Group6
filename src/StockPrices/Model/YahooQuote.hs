{-# LANGUAGE DeriveGeneric, DeriveAnyClass  #-}

module StockPrices.Model.YahooQuote where

import Data.Aeson
import Data.Text
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromField
import Database.PostgreSQL.Simple.FromRow
import Data.Time

data YahooQuote = YahooQuote {
 date :: Day,
 open :: Double,
 high :: Double ,
 low :: Double ,
 close :: Double ,
 volume :: Double ,
 adjClose :: Double
}
 deriving (Show,Generic, ToJSON)

instance FromJSON YahooQuote
instance FromRow YahooQuote where
    fromRow = do
        date  <- field
        open  <- field
        high <- field
        low  <- field
        close  <- field
        volume  <- field
        adj  <- field
        return $ YahooQuote date open high low close volume adj
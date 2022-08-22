{-# LANGUAGE DeriveGeneric, OverloadedStrings  #-}
module StockPrices.Model.TranslateRsponse where

import Data.Aeson
import StockPrices.Model.YahooQuote
import GHC.Generics (Generic)

data TranslateRsponse = TranslateRsponse {
 results :: [YahooQuote],
 total :: Int,
 offset :: Int
}
 deriving (Show,Generic)


instance FromJSON TranslateRsponse